# observium
Observium docker image and docker-compose.yml
Собран вместе с RANCID (ежедневный бэкап конфигураций mikrotik) и syslog (можете отправлять все логи с хостов на observer)

## Простой способ (docker-compose):
1. У вас должен быть установлен [docker](https://docs.docker.com/engine/installation/), [docker-compose](https://docs.docker.com/compose/install/) и git

2. Скачиваем репозиторий:
```
$ git clone https://github.com/BlackoJack/observium.git observium
$ cd observium
```

3. 
      - Открываем `mysql.env`, если хотим меняем пользователя, имя базы, пароль root и пароль пользователя базы
      - Открываем `observium.env`, меняем Домен на свой, данные администратора админки и данные snmp(community, location, contact). Все пробелы и спецсимволы должны быть экранированы слэшем \. В примере показано.
      - Если нужно поменять Timezone или Lang, открываем `system.env` и меняем

4. Открываем docker-compose.yml
      - По желанию меняем порты. В данном случае используется порт 8080 - админка и порт 514/udp - syslog-сервер
      - Проверяем все пути в разделах volumes, при желании меняем, там будут хранится разные данные, а именно:
- `/data/docker/observium/data/mysql` - сама база MySQL
- `/data/docker/observium/data/rrd` - графики rrd
- `/data/docker/observium/data/logs` - различные логи observium-а
- `/data/docker/observium/data/html` - html файлы
- `/data/docker/observium/data/mibs` - mibs snmp
- `/data/docker/observium/data/scripts` - скрипты (могут понадобится для linux-хостов, документация в офф. мане [тут](http://docs.observium.org/unix_agent/) и [тут](http://docs.observium.org/apps/))
- `/data/docker/observium/data/ssh_keys` - сюда нужно положить ключ id_rsa. Про ключ читаем в конце
- `/data/docker/observium/data/rancid_configs` - сюда RANCID будет скидывать конфигурации Mikrotik-ов
- `/data/docker/observium/data/rancid_logs` - логи RANCID

5. Запускаем сервис:
```
$ docker-compose up -d
```

6. Для чего ключ id_rsa?
С помощью ключа служба RANCID должна заходить на устройства Mikrotik безпарольно, чтобы забирать конфигурации. Внимание! passphrase на ключ должен быть пустым. Пользователь на mikrotik должен называться rancid
      - Чтобы сделать ключ на linux выполняем:
```
$ ssh-keygen -t rsa
$ scp ~/.ssh/id_rsa.pub admin@<mikrotik_ip>:mykey.pub
```
Passphrase! не заполняем. Заводим пользователя rancid на mikrotik(можно только для чтения) и импортируем ему наш ключ:
```
> user ssh-keys import user=rancid public-key-file=mykey.pub
```
