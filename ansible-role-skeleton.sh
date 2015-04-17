#!/bin/sh
ROLE_NAME=$1
SERVICE_NAME=$1
ROLE_PATH=./roles/$ROLE_NAME
USER_NAME=`git config user.name`
USER_EMAIL=`git config user.email`


if [ $# != 1 ] ; then
	echo "Missing argument role name"
	exit 1
fi

for path in defaults handlers tasks templates vars ; do
	[ -d $ROLE_PATH/$path ] || mkdir -p $ROLE_PATH/$path
done

cat <<EOF > $ROLE_PATH/defaults/main.yml
---
# Package states: installed or latest
${ROLE_NAME}_pkg_state: installed

# Service states: started or stopped
${ROLE_NAME}_service_state: started

# Service enabled on startup: yes or no
${ROLE_NAME}_service_enabled: yes
EOF

cat <<EOF > $ROLE_PATH/handlers/main.yml
---
- name: restart ${ROLE_NAME}
  service: name=${SERVICE_NAME} state=restarted

- name: reload ${ROLE_NAME}
  service: name=${SERVICE_NAME} state=reloaded

EOF

cat <<EOF > $ROLE_PATH/tasks/main.yml
---
- name: install ${ROLE_NAME} for Debian OS family
  apt: pkg=${SERVICE_NAME} state={{ ${ROLE_NAME}_pkg_state }}
  when: ansible_os_family == 'Debian'
  tags: ["packages","${ROLE_NAME}"]

- name: install ${ROLE_NAME} for RedHat OS family
  yum: name=${SERVICE_NAME} state={{ ${ROLE_NAME}_pkg_state }}
  when: ansible_os_family == 'RedHat'
  tags: ["packages","${ROLE_NAME}"]

- name: configure ${ROLE_NAME}
  template: src=${SERVICE_NAME}.conf.j2 dest=/etc/${SERVICE_NAME}.conf
  notify: restart ${ROLE_NAME}
  tags: ["configuration","${ROLE_NAME}"]

- name: ensure ${ROLE_NAME} is started/stopped
  service: name=${SERVICE_NAME} state={{ ${ROLE_NAME}_service_state }} enabled={{ ${ROLE_NAME}_service_enabled }}
  tags: ["service","${ROLE_NAME}"]

EOF

cat <<EOF > $ROLE_PATH/templates/$SERVICE_NAME.conf.j2
# {{ ansible_managed }}

EOF


cat <<EOF > $ROLE_PATH/vars/main.yml
---

EOF
