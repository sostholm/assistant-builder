#!/bin/bash
set -e

# Define a mapping between repository directories and expected environment variable names
declare -A repos
repos=(
  ["assistant-voice-server"]="ASSISTANT_VOICE_SERVER_COMMIT"
  ["assistant_process_audio"]="ASSISTANT_PROCESS_AUDIO_COMMIT"
  ["assistant-conversation-backend"]="ASSISTANT_CONVERSATION_BACKEND_COMMIT"
  ["assistant-admin-app"]="ASSISTANT_ADMIN_APP_COMMIT"
)

# Function to update repository using a commit hash provided via ENV variable,
# then install any updated requirements.
update_repo() {
    local repo_dir=$1
    local env_var=$2
    cd "/app/$repo_dir"
    git fetch origin
    if [ -n "${!env_var}" ]; then
        echo "Checking out commit ${!env_var} for repository $repo_dir"
        git checkout ${!env_var}
    else
        echo "No commit specified for repository $repo_dir. Staying on the current branch."
        # Optionally, you can enforce a default behavior:
        # git checkout origin/main
    fi

    # Check if a requirements file exists and install dependencies if it does.
    if [ -f requirements.txt ]; then
        echo "Installing Python dependencies for repository $repo_dir"
        pip install -r requirements.txt
    else
        echo "No requirements.txt found for repository $repo_dir."
    fi
    cd -
}

# Iterate over the repositories and update them accordingly
for repo in "${!repos[@]}"; do
    update_repo "$repo" "${repos[$repo]}"
done

# Start supervisord to launch your services
exec supervisord -c /etc/supervisor/supervisord.conf