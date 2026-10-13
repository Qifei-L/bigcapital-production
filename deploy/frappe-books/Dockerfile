FROM node:24-bookworm-slim AS node
FROM python:3.14-slim-trixie
ENV DEBIAN_FRONTEND=noninteractive UV_PYTHON_DOWNLOADS=never FRAPPE_SERVE_ASSETS=1
COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules/ /usr/local/lib/node_modules/
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
 && npm install -g yarn@1.22.22 \
 && apt-get update && apt-get install -y --no-install-recommends git curl ca-certificates build-essential pkg-config libcups2-dev libmariadb-dev libpq-dev libpango-1.0-0 libharfbuzz-subset0 redis-server util-linux \
 && pip install --no-cache-dir frappe-bench uv \
 && useradd -m -u 1000 -s /bin/bash frappe && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /opt/frappe-source /opt/frappe-books \
 && curl -fsSL https://codeload.github.com/frappe/frappe/tar.gz/5395b683e2be865f7fd70ea5df5cd8205ebce6fc | tar xz --strip-components=1 -C /opt/frappe-source \
 && curl -fsSL https://codeload.github.com/frappe/frappe-books/tar.gz/7a1822912f6058e9a242cda8d13a1572a0c0a5c9 | tar xz --strip-components=1 -C /opt/frappe-books \
 && cd /opt/frappe-source && git init -b develop && git add . && git -c user.name=Build -c user.email=build@example.invalid commit -qm 'Pinned upstream snapshot' \
 && chown -R frappe:frappe /opt/frappe-source /opt/frappe-books
USER frappe
RUN bench init /home/frappe/frappe-bench --frappe-path file:///opt/frappe-source --frappe-branch develop --python /usr/local/bin/python3.14 --skip-assets --no-backups --no-procfile --skip-redis-config-generation
WORKDIR /home/frappe/frappe-bench
RUN bench get-app --soft-link --skip-assets /opt/frappe-books && bench build
USER root
RUN cp -aL sites /opt/built-sites && rm -rf sites && ln -s /data/sites sites
COPY deploy/frappe-books/entrypoint.sh /usr/local/bin/books-entrypoint
COPY deploy/frappe-books/bootstrap.sh /opt/books-bootstrap.sh
COPY deploy/frappe-books/setup_demo.py /opt/setup_demo.py
COPY deploy/frappe-books/run_books.py /opt/run_books.py
RUN chmod +x /usr/local/bin/books-entrypoint /opt/books-bootstrap.sh
EXPOSE 8000
ENTRYPOINT ["/usr/local/bin/books-entrypoint"]
