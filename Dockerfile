FROM python:3.11-slim

WORKDIR /

RUN apt-get update && apt-get install --yes --no-install-recommends curl gcc libc-dev libffi-dev && rm -rf /var/lib/apt/lists/*

RUN pip3 install poetry
# https://github.com/rust-lang/cargo/issues/8719#issuecomment-1253575253
#ENV PATH=/root/.cargo/bin:$PATH
#RUN --mount=type=tmpfs,target=/root/.cargo curl https://sh.rustup.rs -sSf | bash -s -- -y && pip install poetry

COPY poetry.lock /
COPY pyproject.toml /

RUN poetry config virtualenvs.create false && \
    poetry install --no-interaction --no-dev --no-ansi

FROM python:3.11-slim

WORKDIR /

# copy pre-built packages to this image
COPY --from=0 /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages

# now copy the actual code we will execute (poetry install above was just for dependencies)
COPY kube_ops_view /kube_ops_view

ARG VERSION=dev

RUN sed -i "s/__version__ = .*/__version__ = '${VERSION}'/" /kube_ops_view/__init__.py

ENTRYPOINT ["python3", "-m", "kube_ops_view"]
