##  Початок
```bash
docker compose build

docker compose up -d

docker compose ps
docker logs metrics-collector -f

# http://localhost:3000 (admin/admin123)

docker exec -d ueransim bash -c "cd /root/ueransim/build && ./nr-gnb -c /root/ueransim-config/gnb.yaml"

./realistic-5g-traffic.sh
```


### Функції основної мережі 5G
- **AMF** (10.10.0.50): управління доступом і мобільністю
- **SMF** (10.10.0.7): управління сеансами
- **UPF** (10.10.0.8): функція користувацького рівня
- **NRF** (10.10.0.12): Репозиторій NF
- **SCP** (10.10.0.35): Проксі-сервер комунікації послуг
- **AUSF** (10.10.0.11): Сервер автентифікації
- **UDM** (10.10.0.13): Уніфіковане управління даними
- **UDR** (10.10.0.14): Уніфіковане сховище даних
- **PCF** (10.10.0.27): Контроль політики
- **NSSF** (10.10.0.28): Вибір сегмента мережі
- **BSF** (10.10.0.29): Підтримка зв'язування


**Структура конфігурації:**
```
config-templates/
├── amf/
│   ├── amf_init.sh    # Substitutes env vars
│   └── amf.yaml       # Template with placeholders
└── ...
```
##Вимоги 

- Docker & Docker Compose
- 4GB+ RAM
- Linux kernel with TUN/TAP support

## Дебагінг

**Конфлікти мережі:**
```bash
docker compose down -v
docker network prune -f
docker compose up -d
```

**Логи:**
```bash
docker logs <service-name> -f
```

**Перезапуск:**
```bash
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
docker network prune -f
docker compose up -d
```
