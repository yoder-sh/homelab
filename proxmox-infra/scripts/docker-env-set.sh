export PROTON_USERNAME=$(aws ssm get-parameter --name "/homelab/protonvpn-username" --with-decryption --query "Parameter.Value" --output text)
export PROTON_PASSWORD=$(aws ssm get-parameter --name "/homelab/protonvpn-password" --with-decryption --query "Parameter.Value" --output text)
export CF_TOKEN=$(aws ssm get-parameter --name "/homelab/cf-token" --with-decryption --query "Parameter.Value" --output text)
export NC_MYSQL_ROOT_PW=$(aws ssm get-parameter --name "/homelab/nextcloud-root-pw" --with-decryption --query "Parameter.Value" --output text)
export NC_MYSQL_PW=$(aws ssm get-parameter --name "/homelab/nextcloud-pw" --with-decryption --query "Parameter.Value" --output text)

export MUSE_DISCORD_TOKEN=$(aws ssm get-parameter --name "/homelab/muse/DISCORD_TOKEN" --with-decryption --query "Parameter.Value" --output text)
export MUSE_YOUTUBE_API_KEY=$(aws ssm get-parameter --name "/homelab/muse/YOUTUBE_API_KEY" --with-decryption --query "Parameter.Value" --output text)
export MUSE_SPOTIFY_CLIENT_ID=$(aws ssm get-parameter --name "/homelab/muse/SPOTIFY_CLIENT_ID" --with-decryption --query "Parameter.Value" --output text)
export MUSE_SPOTIFY_CLIENT_SECRET=$(aws ssm get-parameter --name "/homelab/muse/SPOTIFY_CLIENT_SECRET" --with-decryption --query "Parameter.Value" --output text)
export PLEX_CLAIM_TOKEN=$(aws ssm get-parameter --name "/homelab/plex/claim-token" --with-decryption --query "Parameter.Value" --output text)


