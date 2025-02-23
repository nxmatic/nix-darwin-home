FROM debian:bookworm

# Update system and install required commands
RUN <<'EOS' cut -c 5- | bash -exo pipefail
    apt-get update -y
    apt-get upgrade -y
    apt-get install -y coreutils debianutils avahi-utils curl
EOS
 
RUN --mount=type=secret,id=k3s_token <<'EOS' cut -c 5- | bash -exo pipefail    
    curl -sfL https://get.k3s.io | K3S_URL=https://bioskop.local:6443 K3S_TOKEN="$( cat /run/secrets/k3s_token )"
EOS

