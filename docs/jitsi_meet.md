
# Jitsi Meet

## Docker

Docker instructions
<https://jitsi.github.io/handbook/docs/devops-guide/devops-guide-docker>.

The containers will start automatically on boot by default.

### Environment variables

Docker scripts support undocumented environment variables. All supported
variables are in docker-compose.yml.
<https://github.com/jitsi/docker-jitsi-meet/blob/master/docker-compose.yml>

Check scripts to know what the environment variables will do. For example

* <https://github.com/jitsi/docker-jitsi-meet/blob/master/web/rootfs/defaults/settings-config.js>
* <https://github.com/jitsi/docker-jitsi-meet/blob/master/prosody/rootfs/defaults/conf.d/jitsi-meet.cfg.lua>
* <https://github.com/jitsi/docker-jitsi-meet/blob/master/jvb/rootfs/defaults/jvb.conf>

When environment variables are changed containers need to be recreated.
```
docker-compose stop && docker-compose rm && docker-compose up -d
```

### Other config

If environment variables do not offer enough configuration at least
`~/.jitsi-meet-cfg/web/config.js` and
`~/.jitsi-meet-cfg/web/interface_config.js`
can be modified partially. Docker scripts will
append `~/.jitsi-meet-cfg/web/custom-config.js` and
`~/.jitsi-meet-cfg/web/custom-interface_config.js`
to previous files.

Available config options info:

* <https://github.com/jitsi/jitsi-meet/blob/master/config.js>
* <https://github.com/jitsi/jitsi-meet/blob/master/interface_config.js>
* <https://github.com/jitsi/jitsi-meet/blob/master/react/features/base/config/configType.ts>

Docker containers must be restarted after modifying config files
with file name staring with `custom-`. That can be done with
command `docker-compose restart`.

## JWT authentication

JWT info <https://github.com/jitsi/lib-jitsi-meet/blob/master/doc/tokens.md>

## Troubleshooting

If UI config changes does not seem to be effective check meeting page source
code. Files config.js and interface_config.js are included in it. Check
also web browser console for errors.

## Example config

Extra .env config

```sh
ENABLE_BREAKOUT_ROOMS=false
ENABLE_WELCOME_PAGE=false
ENABLE_CLOSE_PAGE=true
DISABLE_POLLS=true
DISABLE_REACTIONS=true
DISABLE_REMOTE_VIDEO_MENU=true
DISABLE_PRIVATE_CHAT=true
DISABLE_KICKOUT=true
DISABLE_GRANT_MODERATOR=true
DISABLE_LOCAL_RECORDING=true
DISABLE_PROFILE=true
MAX_PARTICIPANTS=2
CODEC_ORDER_JVB="['H264', 'VP8', 'VP9', 'AV1']"
CODEC_ORDER_JVB_MOBILE="['H264', 'VP8', 'VP9', 'AV1']"
CODEC_ORDER_P2P="['H264', 'VP8', 'VP9', 'AV1']"
CODEC_ORDER_P2P_MOBILE="['H264', 'VP8', 'VP9', 'AV1']"
```

custom-config.js

```json
// Privacy
config.disableThirdPartyRequests = true;
config.doNotStoreRoom = true;

// Pre-meeting UI
config.hiddenPremeetingButtons = ['invite'];
config.readOnlyName = true;

// UI
config.analytics = { disabled: true };
config.speakerStats = { disabled: true };
config.disableVirtualBackground = true;
config.hideConferenceSubject = true;
config.hideDisplayName = true;
config.hideDominantSpeakerBadge = true;
config.disableModeratorIndicator = true;

config.participantsPane = {
    enabled: true,
    hideModeratorSettingsTab: true,
    hideMoreActionsButton: true,
    hideMuteAllButton: true,
};

config.toolbarButtons = [
    'camera',
    'filmstrip',
    'fullscreen',
    'hangup',
    'microphone',
    'participants-pane',
    'settings',
    'tileview',
    'toggle-camera',
];
```
