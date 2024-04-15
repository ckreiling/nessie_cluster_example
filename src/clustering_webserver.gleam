import gleam/bytes_builder
import gleam/dynamic
import gleam/erlang/atom
import gleam/erlang/node
import gleam/erlang/os
import gleam/erlang/process
import gleam/http/response.{Response}
import gleam/list
import gleam/option
import gleam/otp/actor
import gleam/otp/supervisor
import gleam/result
import gleam/string
import mist
import nessie_cluster

pub fn main() {
  // Initialize DNS clustering
  let dns_query = case os.get_env("FLY_APP_NAME") {
    Ok(app_name) -> nessie_cluster.DnsQuery(app_name <> ".internal")
    Error(Nil) -> nessie_cluster.Ignore
  }
  let cluster = nessie_cluster.with_query(nessie_cluster.new(), dns_query)
  let cluster_worker = fn(_) { nessie_cluster.start_spec(cluster, option.None) }

  // Initialize web server
  let web =
    web_service
    |> mist.new()
    |> mist.port(8080)
  let web_worker = fn(_) {
    web
    |> mist.start_http()
    |> result.map_error(fn(e) { actor.InitCrashed(dynamic.from(e)) })
  }

  let assert Ok(_) =
    supervisor.start(fn(children) {
      children
      |> supervisor.add(supervisor.worker(cluster_worker))
      |> supervisor.add(supervisor.worker(web_worker))
    })

  process.sleep_forever()
}

fn web_service(_request) {
  let nodes =
    node.visible()
    |> list.map(fn(a) { atom.to_string(node.to_atom(a)) })
    |> string.join(", ")

  let me = atom.to_string(node.to_atom(node.self()))

  let res = bytes_builder.from_string("me: " <> me <> "\npeers: " <> nodes)

  Response(200, [], mist.Bytes(res))
}
