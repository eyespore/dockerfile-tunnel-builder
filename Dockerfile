FROM kroniak/ssh-client

RUN apk update && apk add sshpass autossh

ARG USERNAME=appuser
ARG UID=1000
ARG GID=1000

RUN addgroup -g $GID $USERNAME \
    && adduser -D -u $UID -G $USERNAME $USERNAME

USER $USERNAME
WORKDIR /home/$USERNAME
