# Use the official Hyperledger Besu image as the base image
FROM hyperledger/besu:23.10.2

# Set the user to root to ensure we have the necessary permissions
USER root

# Create directories for Besu configuration and keys
RUN mkdir -p /opt/besu/config /opt/besu/besu/keys && \
    chown -R besu:besu /opt/besu && \
    chmod -R 700 /opt/besu/config

# Copy the Besu configuration files into the container
COPY config/besu /opt/besu/config/besu

# Expose the necessary ports
EXPOSE 8545 8546 9545

# Set the ENTRYPOINT to run Besu with the specified configuration
ENTRYPOINT ["besu"]
CMD ["--config-file=/opt/besu/config/besu/config.toml", \
     "--genesis-file=/opt/besu/config/besu/genesis.json", \
     "--static-nodes-file=/opt/besu/config/besu/static-nodes.json"]
