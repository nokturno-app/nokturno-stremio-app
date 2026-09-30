# Nokturno pro Stremio v kontejneru. Doplněk nemá žádné závislosti mimo standardní knihovnu,
# stačí slim obraz a složka `nokturno/` z vydání (workflow docker.yml ji rozbalí vedle).
FROM python:3.12-slim
LABEL org.opencontainers.image.source="https://github.com/nokturno-app/nokturno-stremio-app" org.opencontainers.image.description="Nokturno pro Stremio a Nuvio"

RUN useradd --create-home --uid 10001 nokturno
WORKDIR /app
COPY nokturno/ ./nokturno/

# /data = cache a nastavení; bez svazku se po každém restartu tahá znovu
ENV NOKTURNO_HOST=0.0.0.0 \
    NOKTURNO_PORT=7140 \
    NOKTURNO_DATA=/data \
    PYTHONUNBUFFERED=1
RUN mkdir -p /data && chown nokturno:nokturno /data
VOLUME ["/data"]
USER nokturno
EXPOSE 7140

HEALTHCHECK --interval=60s --timeout=5s --start-period=15s \
    CMD python3 -c "import urllib.request,sys; sys.exit(0 if urllib.request.urlopen('http://127.0.0.1:7140/health', timeout=4).status == 200 else 1)"

CMD ["python3", "-m", "nokturno.server"]
