FROM elixir:1.9-alpine

COPY . /app

WORKDIR /app

RUN mix local.hex --force && mix local.rebar --force && mix deps.get
RUN MIX_ENV=prod mix release

FROM elixir:1.9-alpine

COPY --from=0 /app/_build/prod/rel/changi /app

WORKDIR /app

ENV PORT=8080
EXPOSE 8080/tcp

CMD ["/app/bin/changi", "start"]
