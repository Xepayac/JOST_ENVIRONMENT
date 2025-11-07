# Use the official NixOS image as a base to ensure consistency with the IDX environment
FROM nixos/nix

# Set the working directory inside the container
WORKDIR /app

# Copy only the necessary Nix configuration files first to leverage Docker's layer caching
COPY .idx/dev.nix ./.idx/dev.nix

# Install system-level dependencies using the Nix package manager
# This warms the cache and ensures all tools are available before we copy the app code
RUN nix-shell .idx/dev.nix --run "echo 'Nix environment dependencies installed.'"

# Copy the rest of the application source code into the container
COPY . .

# Install Python dependencies into the virtual environment defined by Nix
# This includes our local `jost_engine` package
RUN nix-shell .idx/dev.nix --run "source .venv/bin/activate && pip install -r requirements.txt && pip install -e backend"

# Expose the port that Gunicorn will run on
EXPOSE 8080
