# Remote admin bot

## MacOS

Make sure that you have
`~/afrodite/afrodite-backend` and
`~/llama.cpp/build/bin/llama-server`
binaries available.

Also download Gemma 3 files from
<https://huggingface.co/ggml-org/gemma-3-27b-it-qat-GGUF> to
`~/models/gemma3/gemma-3-27b-it-qat-Q4_0.gguf` and
`~/models/gemma3/mmproj-model-f16-27B.gguf`.

Create remote bot config to `~/afrodite/bots.toml`.

> [!IMPORTANT]
> Change API_URL, ACCOUNT_ID and PASSWORD to valid values.

```toml
[remote_bot_mode]
api_url = "API_URL"

[admin_bot_config]
account_id = "ACCOUNT_ID"
remote_bot_login_password = "PASSWORD"

[content_moderation]
initial_content = true
added_content = true
default_action = "reject"

[content_moderation.llm_primary]
openai_api_url = "http://localhost:11434/v1"
model = "gemma3:27b"
system_text = """\
    You are dating app content moderator, who classifies \
    user profile pictures to \
    'Accepted' or 'Rejected' categories. \
    Profile picture is 'Rejected', when it contains unwanted content for \
    a dating app, for example NSFW content."""
expected_response = "accepted"
move_accepted_to_human_moderation = false
move_rejected_to_human_moderation = false
ignore_rejected = false
delete_accepted = false
max_tokens = 10000
add_llm_output_to_rejection_details = true

[profile_text_moderation]
accept_single_visible_character = true
default_action = "reject"

[profile_text_moderation.llm]
openai_api_url = "http://localhost:11434/v1"
model = "gemma3:27b"
system_text = """\
    You are dating app content moderator, who classifies \
    user profile texts to \
    'Accepted' or 'Rejected' categories. \
    Profile text is 'Rejected', when it contains unwanted content for \
    a dating app, for example NSFW content."""
user_text_template = "Profile text:\n\n{text}"
expected_response = "accepted"
move_rejected_to_human_moderation = false
max_tokens = 10000
add_llm_output_to_rejection_details = true
```

### Services

> [!IMPORTANT]
> Change all USER texts to your username.

`/Library/LaunchDaemons/com.example.llama-server.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.example.llama-server</string>

    <key>UserName</key>
    <string>USER</string>

    <key>GroupName</key>
    <string>staff</string>

    <key>ProgramArguments</key>
    <array>
        <string>/Users/USER/llama.cpp/build/bin/llama-server</string>
        <string>--log-verbosity</string>
        <string>2</string>
        <string>-m</string>
        <string>/Users/USER/models/gemma3/gemma-3-27b-it-qat-Q4_0.gguf</string>
        <string>--mmproj</string>
        <string>/Users/USER/models/gemma3/mmproj-model-f16-27B.gguf</string>
    </array>

    <key>Nice</key>
    <integer>11</integer>

    <key>KeepAlive</key>
    <true/>

    <key>RunAtLoad</key>
    <true/>

    <key>StandardOutPath</key>
    <string>/Users/USER/afrodite/llama-server.log</string>

    <key>StandardErrorPath</key>
    <string>/Users/USER/afrodite/llama-server.error.log</string>

    <key>ThrottleInterval</key>
    <integer>10</integer>
</dict>
</plist>
```

`/Library/LaunchDaemons/com.example.afrodite-bot.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.example.afrodite-bot</string>

    <key>UserName</key>
    <string>USER</string>

    <key>GroupName</key>
    <string>staff</string>

    <key>ProgramArguments</key>
    <array>
        <string>/Users/USER/afrodite/afrodite-backend</string>
        <string>remote-bot</string>
        <string>--bot-config</string>
        <string>/Users/USER/afrodite/bots.toml</string>
    </array>

    <key>WorkingDirectory</key>
    <string>/Users/USER/afrodite</string>

    <key>EnvironmentVariables</key>
    <dict>
        <key>RUST_LOG</key>
        <string>info</string>
    </dict>

    <key>Nice</key>
    <integer>10</integer>

    <key>KeepAlive</key>
    <dict>
        <key>SuccessfulExit</key>
        <true/>
        <key>OtherJobEnabled</key>
        <dict>
            <key>com.example.llama-server</key>
            <true/>
        </dict>
    </dict>

    <key>RunAtLoad</key>
    <true/>

    <key>StandardOutPath</key>
    <string>/Users/USER/afrodite/afrodite.log</string>

    <key>StandardErrorPath</key>
    <string>/Users/USER/afrodite/afrodite.error.log</string>

    <key>ThrottleInterval</key>
    <integer>10</integer>
</dict>
</plist>
```

```sh
sudo chown root:wheel /Library/LaunchDaemons/com.example.llama-server.plist
sudo chmod 644 /Library/LaunchDaemons/com.example.llama-server.plist

sudo chown root:wheel /Library/LaunchDaemons/com.example.afrodite-bot.plist
sudo chmod 644 /Library/LaunchDaemons/com.example.afrodite-bot.plist

sudo launchctl load /Library/LaunchDaemons/com.example.llama-server.plist
sudo launchctl load /Library/LaunchDaemons/com.example.afrodite-bot.plist
```

Useful commands:

```sh
sudo launchctl list | grep -E "llama|afrodite"
sudo launchctl start SERVICE
sudo launchctl stop SERVICE
tail -f ~/afrodite/*.log
```
