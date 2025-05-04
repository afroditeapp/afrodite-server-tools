
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
* <https://github.com/jitsi/docker-jitsi-meet/blob/master/jicofo/rootfs/defaults/jicofo.conf>

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
ENABLE_END_CONFERENCE=false
ENABLE_AV_MODERATION=false
ENABLE_BREAKOUT_ROOMS=false
ENABLE_WELCOME_PAGE=false
ENABLE_CLOSE_PAGE=true
DISABLE_POLLS=true
DISABLE_REACTIONS=true
DISABLE_PRIVATE_CHAT=true
DISABLE_GRANT_MODERATOR=true
DISABLE_LOCAL_RECORDING=true
DISABLE_PROFILE=true

# The meetings should be one to one video calls but allow more than two
# participants because if a meeting connection breaks it is not possible to
# rejoin the meeting before server detects the broken connection or
# admin kicks out the user with the broken connection from the meeting.
MAX_PARTICIPANTS=4
```

custom-config.js

```json
// Privacy
config.analytics = { disabled: true };
config.disableThirdPartyRequests = true;
config.doNotStoreRoom = true;
config.disableInviteFunctions = true;

// Pre-meeting UI
config.hiddenPremeetingButtons = ['invite'];
config.readOnlyName = true;

// UI
config.speakerStats = { disabled: true };
config.disableVirtualBackground = true;
config.hideConferenceSubject = true;
config.hideDisplayName = true;
config.hideDominantSpeakerBadge = true;
config.disableModeratorIndicator = true;
config.disableRemoteMute = true;

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

custom-interface_config.json

```json
interfaceConfig.SHOW_JITSI_WATERMARK = false;
```

## Automatically close meeting page when meeting ends

This works if the meeting link is opened to a new window or tab.

~/.jitsi-meet-cfg/meeting.html

```html
<!DOCTYPE html>
<html>
  <head>
    <title>Jitsi Meet</title>
    <meta name="viewport" content="width=device-width, height=device-height">
    <script src="https://jitsi.example.com/external_api.js"></script>
    <script>
      function startConference() {
        function getQueryParam(name) {
            const params = new URLSearchParams(window.location.search);
            return params.get(name);
        }

        const options = {
          roomName: getQueryParam("room"),
          jwt: getQueryParam("jwt"),
          parentNode: document.getElementById("jitsi-container"),
          configOverwrite: {},
          interfaceConfigOverwrite: {}
        };

        const api = new JitsiMeetExternalAPI("jitsi.example.com", options);

        api.addEventListener('readyToClose', () => {
          window.close();
        });
      }

      window.onload = startConference;
    </script>
    <style>
        body {
            padding: 0px;
            margin: 0px;
            overflow: hidden;
        }

        #jitsi-container {
            width: 100vw;
            width: 100svw;
            height: 100vh;
            height: 100svh;
        }
    </style>
  </head>
  <body>
    <div id="jitsi-container"></div>
  </body>
</html>
```

Add the HTML file to web container by modifying docker-compose.yml.

```yaml
services:
    web:
        volumes:
            - ${CONFIG}/meeting.html:/usr/share/jitsi-meet/static/meeting.html:Z
```

After recreating containers it is possible to start meetings with URLs like

```
https://jitsi.example.com/static/meeting.html?room=ROOM&jwt=JWT
```
