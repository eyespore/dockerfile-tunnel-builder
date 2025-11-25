FROM kroniak/ssh-client
RUN apk update && apk add sshpass autossh
