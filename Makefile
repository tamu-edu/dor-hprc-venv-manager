# ModuLair Makefile
# Builds and installs the ModuLair virtual environment management tools

# Configuration
ROOTDIR := $(PWD)
BINDIR := $(ROOTDIR)/bin
LOGDIR := $(ROOTDIR)/logs
SRCDIR := $(ROOTDIR)/src

# Metadata locations
ifndef METDIR
$(error METDIR must be specified. Example: make install METDIR="/your/user/metadata/path")
endif

ifndef GROUPMETDIR
$(error GROUPMETDIR must be specified. Example: make install GROUPMETDIR="/your/group/metadata/path")
endif

# Template and output files
TEMPLATES := activate_venv.template list_venvs.template create_venv.template delete_venv.template add_venv.template utils.py.template json_to_command.template
SCRIPTS := activate_venv list_venvs create_venv delete_venv utils.py json_to_command add_venv

# Default target
.PHONY: all
all: build

# Build target - processes templates and prepares scripts
.PHONY: build
build: directories $(SCRIPTS)
	@echo "Build completed successfully!"
	@echo "Binary directory: $(BINDIR)"
	@echo "Log directory: $(LOGDIR)"
	@echo "User metadata location: $(METDIR)"
	@echo "Group metadata location: $(GROUPMETDIR)"

# Create necessary directories
.PHONY: directories
directories:
	@echo "Creating directories..."
	@mkdir -p $(BINDIR)
	@mkdir -p $(LOGDIR)
	@touch $(LOGDIR)/venv.log
	@chmod uog+rw $(LOGDIR)/venv.log 2>/dev/null || echo "Skipped changing permission for $(LOGDIR)/venv.log"

# Template processing rules
activate_venv: $(SRCDIR)/activate_venv.template
	@echo "Processing activate_venv..."
	@cp $< $@
	@sed -i 's|<BINDIR>|$(BINDIR)|g' $@
	@sed -i 's|<LOGDIR>|$(LOGDIR)|g' $@
	@chmod +x $@ 2>/dev/null || echo "Skipped changing permission for $@"

list_venvs: $(SRCDIR)/list_venvs.template
	@echo "Processing list_venvs..."
	@cp $< $@
	@sed -i 's|<LOGDIR>|$(LOGDIR)|g' $@
	@sed -i 's|<METDIR>|$(METDIR)|g' $@
	@sed -i 's|<GROUPMETDIR>|$(GROUPMETDIR)|g' $@
	@chmod +x $@ 2>/dev/null || echo "Skipped changing permission for $@"

create_venv: $(SRCDIR)/create_venv.template
	@echo "Processing create_venv..."
	@cp $< $@
	@sed -i 's|<LOGDIR>|$(LOGDIR)|g' $@
	@sed -i 's|<METDIR>|$(METDIR)|g' $@
	@sed -i 's|<GROUPMETDIR>|$(GROUPMETDIR)|g' $@
	@chmod +x $@ 2>/dev/null || echo "Skipped changing permission for $@"

delete_venv: $(SRCDIR)/delete_venv.template
	@echo "Processing delete_venv..."
	@cp $< $@
	@sed -i 's|<LOGDIR>|$(LOGDIR)|g' $@
	@sed -i 's|<METDIR>|$(METDIR)|g' $@
	@sed -i 's|<GROUPMETDIR>|$(GROUPMETDIR)|g' $@
	@chmod +x $@ 2>/dev/null || echo "Skipped changing permission for $@"

add_venv:
	@echo "Processing add_venv..."
	@if [ -f "$(SRCDIR)/add_venv.template" ]; then \
		cp $(SRCDIR)/add_venv.template $@ && \
		sed -i 's|<LOGDIR>|$(LOGDIR)|g' $@ && \
		sed -i 's|<METDIR>|$(METDIR)|g' $@ && \
		sed -i 's|<GROUPMETDIR>|$(GROUPMETDIR)|g' $@; \
	elif [ -f "$(SRCDIR)/add_venv" ]; then \
		cp $(SRCDIR)/add_venv $@ && \
		sed -i 's|<LOGDIR>|$(LOGDIR)|g' $@ && \
		sed -i 's|<METDIR>|$(METDIR)|g' $@ && \
		sed -i 's|<GROUPMETDIR>|$(GROUPMETDIR)|g' $@; \
	else \
		echo "Error: Neither add_venv.template nor add_venv found in $(SRCDIR)"; \
		exit 1; \
	fi
	@chmod +x $@ 2>/dev/null || echo "Skipped changing permission for $@"

json_to_command:
	@echo "Processing json_to_command..."
	@if [ -f "$(SRCDIR)/json_to_command.template" ]; then \
		cp $(SRCDIR)/json_to_command.template $@ && \
		sed -i 's|<GROUPMETDIR>|$(GROUPMETDIR)|g' $@; \
	elif [ -f "$(SRCDIR)/json_to_command" ]; then \
		cp $(SRCDIR)/json_to_command $@ && \
		sed -i 's|<GROUPMETDIR>|$(GROUPMETDIR)|g' $@; \
	else \
		echo "Error: Neither json_to_command.template nor json_to_command found in $(SRCDIR)"; \
		exit 1; \
	fi

utils.py: $(SRCDIR)/utils.py.template
	@echo "Processing utils.py..."
	@cp $< $@
	@sed -i 's|<METDIR>|$(METDIR)|g' $@
	@sed -i 's|<GROUPMETDIR>|$(GROUPMETDIR)|g' $@

# Install target - copies processed scripts to bin directory
.PHONY: install
install: build
	@echo "Installing scripts to $(BINDIR)..."
	@mv activate_venv $(BINDIR)/
	@mv list_venvs $(BINDIR)/
	@mv create_venv $(BINDIR)/
	@mv delete_venv $(BINDIR)/
	@mv utils.py $(BINDIR)/
	@mv json_to_command $(BINDIR)/
	@mv add_venv $(BINDIR)/
	@chmod +x $(BINDIR)/* 2>/dev/null || echo "Skipped changing permission for $(BINDIR)"
	@echo ""
	@echo "Installation completed successfully!"
	@echo ""
	@echo "Configuration used:"
	@echo "  User metadata location: $(METDIR)"
	@echo "  Group metadata location: $(GROUPMETDIR)"
	@echo "  Binary directory: $(BINDIR)"
	@echo ""
	@echo "To use ModuLair tools, add the following to your PATH:"
	@echo "  export PATH=\"$(BINDIR):\$$PATH\""
	@echo ""
	@echo "Available tools:"
	@echo "  - create_venv: Create new virtual environments"
	@echo "  - list_venvs: List existing virtual environments"
	@echo "  - activate_venv: Generate activation commands (use with 'source')"
	@echo "  - delete_venv: Delete virtual environments"
	@echo "  - add_venv: Add existing virtual environments to management"

# Development build target
.PHONY: dev
dev: directories $(SCRIPTS)
	@echo "Development build completed!"
	@echo "Scripts are ready for testing in the current directory."
	@echo "Use 'make install' to move them to the bin directory."


# Clean log target - removes generated logs
.PHONY: clean-log
clean-log: 
	@echo "Removing logs..."
	@rm -rf $(LOGDIR)
	@echo "Log clean completed."

# Clean all target - removes generated files and logs
.PHONY: clean-all
clean-all: 
	@echo "Removing generated files and logs..."
	@rm -rf $(BINDIR) $(LOGDIR)
	@echo "Full clean completed."

# Help target
.PHONY: help
help:
	@echo "ModuLair Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  all         - Build the project (default)"
	@echo "  build       - Process templates and prepare scripts"
	@echo "  install     - Build and install scripts to bin directory"
	@echo "  dev         - Development build (build but don't install)"
	@echo "  clean-all   - Remove generated files and logs"
	@echo "  clean-log   - Remove logs"
	@echo "  help        - Show this help message"
	@echo ""
	@echo "Configuration variables (REQUIRED):"
	@echo "  METDIR      - User metadata directory location (REQUIRED)"
	@echo "  GROUPMETDIR - Group metadata directory location (REQUIRED)"
	@echo ""
	@echo "Examples for different HPC environments:"
	@echo "  # SCRATCH-based systems:"
	@echo "  make install METDIR=/scratch/user/\$$USER GROUPMETDIR=/scratch/group"
	@echo ""
	@echo "  # Home directory systems:"
	@echo "  make install METDIR=/home/\$$USER/.venvs GROUPMETDIR=/shared/groups"
	@echo ""
	@echo "  # Development/testing:"
	@echo "  make dev METDIR=/tmp/\$$USER/test GROUPMETDIR=/tmp/groups"

# Declare all targets as phony to avoid conflicts with files of the same name
.PHONY: all build install dev clean clean-all help directories
