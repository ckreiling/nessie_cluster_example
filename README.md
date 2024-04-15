# nessie_cluster_example

An example using [nessie_cluster](https://github.com/ckreiling/nessie_cluster) on Fly.io to cluster nodes.

```sh
fly launch
fly secrets set ERLANG_COOKIE='supersecretvalue'
fly deploy # if setting the secret doesn't restart nodes
```

For production, considering using https://pwgen.io/ to generate the Erlang cookie.

Now you can add new nodes to the cluster with `fly scale count`:

```sh
fly scale count 6 # scale to 6 machines
```

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
gleam shell # Run an Erlang shell
```
