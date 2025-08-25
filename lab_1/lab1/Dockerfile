FROM python:3.10-slim AS build

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y curl
RUN rm -rf /var/lib/apt/list/*

ENV POETRY_VERSION=1.3.2
RUN curl -sSL https://install.python-poetry.org | python3 -
ENV PATH /root/.local/bin:$PATH

COPY pyproject.toml poetry.lock ./

RUN python -m venv ./venv
RUN  . ./venv/bin/activate && poetry install --only main

FROM python:3.10-slim AS deploy
COPY --from=build /venv /venv
ENV PATH /venv/bin:$PATH
COPY src/main.py .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
