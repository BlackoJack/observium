# observium
Observium docker image and docker-compose.yml

## Простой способ (docker-compose):
1. У вас должен быть установлен [docker](https://docs.docker.com/engine/installation/), [docker-compose](https://docs.docker.com/compose/install/) и git

2. Скачиваем репозиторий:
```
$ git clone https://github.com/BlackoJack/observium.git observium
cd observium
```

3. 
3.1 Открываем mysql.env, если хотим меняем пользователя, имя базы, пароль root и пароль пользователя базы
3.2 Открываем observium.env, меняем Домен на свой, данные администратора админки и данные snmp(community, location, contact). Все пробелы и спецсимволы должны быть экранированы слэшем \. В примере показано.
3.3 Если нужно поменять Timezone или Lang, открываем system.env и меняем

4. Открываем docker-compose.yml
4.1 По желанию меняем порты. В данном случае используется порт 8080 - админка и порт 514/udp - syslog-сервер
4.2 Проверяем все пути в разделах volumes
