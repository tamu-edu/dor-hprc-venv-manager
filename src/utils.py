#!/usr/bin/env python3

"""
Centralized metadata utilities for ModuLair virtual environment manager.
Handles traversing and loading metadata from both user and shared group environments.
"""

import json
import os
import subprocess


def get_user():
    """Get the current username from the SCRATCH path."""
    scratch_path = os.environ.get('SCRATCH')
    user = os.path.basename(scratch_path.rstrip('/'))
    return user


def get_user_groups():
    """Get all groups the current user belongs to."""
    user = get_user()
    groups_command = f"groups {user} > groups.txt"
    remove_command = "rm groups.txt"
    
    subprocess.run(groups_command, shell=True)
    
    group_list = []
    try:
        with open("groups.txt", 'r') as file:
            for line in file:
                parts = line.strip().split(':')
                if len(parts) == 2:
                    group_list = parts[1].strip().split()
                    break
    finally:
        subprocess.run(remove_command, shell=True)
    
    return group_list


def load_user_metadata():
    """Load metadata from user's personal virtual environments."""
    metadata_path = os.path.expandvars("$SCRATCH/virtual_envs/metadata.json")
    
    try:
        with open(metadata_path, 'r') as file:
            return json.load(file)
    except FileNotFoundError:
        return {"environments": []}
    except json.JSONDecodeError as e:
        raise Exception(f"User metadata file is corrupted or not in JSON format: {e}")
    except Exception as e:
        raise Exception(f"Unexpected error reading user metadata: {e}")


def load_group_metadata(group_name):
    """Load metadata from a specific group's shared virtual environments."""
    json_path = os.path.join("/", "scratch", "group", group_name, "virtual_envs", "metadata.json")
    
    try:
        with open(json_path, 'r') as file:
            data = json.load(file)
        return data
    except FileNotFoundError:
        # Silently return empty dict - this is expected for groups without shared environments
        return {"environments": []}
    except json.JSONDecodeError as e:
        print(f"Warning: The metadata file for group '{group_name}' is corrupted or not in JSON format")
        return {"environments": []}
    except PermissionError:
        # Silently return empty dict - user may not have access to all group directories
        return {"environments": []}
    except Exception as e:
        print(f"Warning: Unexpected error occurred while reading metadata for group '{group_name}': {e}")
        return {"environments": []}


def load_all_metadata():
    """
    Load metadata from all accessible sources (user + all groups).
    
    Returns:
        dict: A dictionary with structure:
        {
            'user': {metadata_dict},
            'groups': {
                'group1': {metadata_dict},
                'group2': {metadata_dict},
                ...
            }
        }
    """
    all_metadata = {
        'user': load_user_metadata(),
        'groups': {}
    }
    
    # Load metadata from all user groups
    groups = get_user_groups()
    for group in groups:
        group_metadata = load_group_metadata(group)
        if group_metadata.get('environments'):  # Only include groups with environments
            all_metadata['groups'][group] = group_metadata
    
    return all_metadata


def find_environment_by_name(env_name):
    """
    Find an environment by name across all accessible metadata sources.
    
    Args:
        env_name (str): The name of the environment to find
        
    Returns:
        tuple: (source_type, source_name, environment_dict) or (None, None, None) if not found
               source_type is either 'user' or 'group'
               source_name is the username for 'user' or group name for 'group'
    """
    all_metadata = load_all_metadata()
    
    # Search in user environments first
    for env in all_metadata['user'].get('environments', []):
        if env.get('name') == env_name:
            return ('user', get_user(), env)
    
    # Search in group environments
    for group_name, group_metadata in all_metadata['groups'].items():
        for env in group_metadata.get('environments', []):
            if env.get('name') == env_name:
                return ('group', group_name, env)
    
    return (None, None, None)


def get_environment_path(env_name, source_type, source_name):
    """
    Get the filesystem path for an environment.
    
    Args:
        env_name (str): Name of the environment
        source_type (str): Either 'user' or 'group'
        source_name (str): Username for 'user' or group name for 'group'
        
    Returns:
        str: Full path to the environment directory
    """
    if source_type == 'user':
        scratch = os.environ.get('SCRATCH')
        return os.path.join(scratch, 'virtual_envs', env_name)
    elif source_type == 'group':
        return os.path.join('/', 'scratch', 'group', source_name, 'virtual_envs', env_name)
    else:
        raise ValueError(f"Invalid source_type: {source_type}")


def get_metadata_file_path(source_type, source_name):
    """
    Get the path to the metadata file for a given source.
    
    Args:
        source_type (str): Either 'user' or 'group'
        source_name (str): Username for 'user' or group name for 'group'
        
    Returns:
        str: Full path to the metadata.json file
    """
    if source_type == 'user':
        scratch = os.environ.get('SCRATCH')
        return os.path.join(scratch, 'virtual_envs', 'metadata.json')
    elif source_type == 'group':
        return os.path.join('/', 'scratch', 'group', source_name, 'virtual_envs', 'metadata.json')
    else:
        raise ValueError(f"Invalid source_type: {source_type}")


def update_metadata_file(metadata, source_type, source_name):
    """
    Write updated metadata back to the appropriate file.
    
    Args:
        metadata (dict): The metadata dictionary to write
        source_type (str): Either 'user' or 'group'
        source_name (str): Username for 'user' or group name for 'group'
    """
    metadata_path = get_metadata_file_path(source_type, source_name)
    
    with open(metadata_path, 'w') as file:
        json.dump(metadata, file, indent=4)


def remove_environment_from_metadata(env_name):
    """
    Remove an environment from its metadata file.
    
    Args:
        env_name (str): Name of the environment to remove
        
    Returns:
        tuple: (success, source_type, source_name, removed_env) or (False, None, None, None)
    """
    source_type, source_name, env_dict = find_environment_by_name(env_name)
    
    if source_type is None:
        return (False, None, None, None)
    
    # Load the appropriate metadata
    if source_type == 'user':
        metadata = load_user_metadata()
    else:  # group
        metadata = load_group_metadata(source_name)
    
    # Remove the environment
    environments = metadata.get('environments', [])
    removed_env = None
    
    for i, env in enumerate(environments):
        if env.get('name') == env_name:
            removed_env = environments.pop(i)
            break
    
    if removed_env:
        # Write back the updated metadata
        update_metadata_file(metadata, source_type, source_name)
        return (True, source_type, source_name, removed_env)
    
    return (False, source_type, source_name, None)
