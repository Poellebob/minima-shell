use hyprland::data::Workspace;
use hyprland::event_listener::AsyncEventListener;
use hyprland::shared::HyprDataActive;
use serde::Serialize;
use std::env;
use std::io::Write;
use std::os::unix::net::UnixStream;
use std::thread;
use std::time::Duration;

#[derive(Serialize, Debug)]
struct WorkspaceMsg {
    id: Option<i32>,
    name: Option<String>,
    screen: Option<String>,
}

// Get the full socket path under $HOME
fn socket_path() -> String {
    let home = env::var("HOME").expect("HOME environment variable not set");
    format!("{}/.local/share/minima/workspace.sock", home)
}

// Try to connect once every second until successful
fn connect_socket() -> UnixStream {
    let path = socket_path();
    loop {
        match UnixStream::connect(&path) {
            Ok(stream) => return stream,
            Err(_) => thread::sleep(Duration::from_secs(1)),
        }
    }
}

// Send workspace JSON; connect each time to avoid borrowing issues
fn send_msg(msg: &WorkspaceMsg) -> Result<(), Box<dyn std::error::Error>> {
    let mut stream = connect_socket();
    let json = serde_json::to_string(msg)?;
    let message_with_newline = format!("{}\n", json);
    stream.write_all(message_with_newline.as_bytes())?;
    Ok(())
}

async fn get_active_workspace(id: hyprland::event_listener::WorkspaceEventData) -> WorkspaceMsg {
    let ws_id = Some(id.id);

    if let Ok(ws) = Workspace::get_active_async().await {
        WorkspaceMsg {
            id: ws_id,
            name: Some(ws.name),
            screen: Some(ws.monitor),
        }
    } else {
        WorkspaceMsg {
            id: ws_id,
            name: None,
            screen: None,
        }
    }
}

#[tokio::main]
async fn main() -> hyprland::Result<()> {
    // Immediately send current workspace
    println!("Getting active workspace...");
    if let Ok(ws) = Workspace::get_active_async().await {
        let msg = WorkspaceMsg {
            id: Some(ws.id),
            name: Some(ws.name),
            screen: Some(ws.monitor),
        };
        println!("Sending initial workspace: {:?}", msg);
        if let Err(e) = send_msg(&msg) {
            eprintln!("Server closed socket. Exiting: {}", e);
            return Ok(());
        }
        println!("Initial workspace sent successfully");
    } else {
        eprintln!("Failed to get active workspace");
    }

    let mut listener = AsyncEventListener::new();

    // Helper closure to send workspace events
    listener.add_workspace_changed_handler(|id| {
        Box::pin(async move {
            let msg = get_active_workspace(id).await;
            if let Err(_) = send_msg(&msg) {
                eprintln!("Server closed socket. Exiting.");
                std::process::exit(0);
            }
        })
    });

    listener.add_workspace_added_handler(|id| {
        Box::pin(async move {
            let msg = get_active_workspace(id).await;
            if let Err(_) = send_msg(&msg) {
                eprintln!("Server closed socket. Exiting.");
                std::process::exit(0);
            }
        })
    });

    listener.add_workspace_deleted_handler(|id| {
        Box::pin(async move {
            let msg = get_active_workspace(id).await;
            if let Err(_) = send_msg(&msg) {
                eprintln!("Server closed socket. Exiting.");
                std::process::exit(0);
            }
        })
    });

    listener.add_workspace_moved_handler(|_| {
        Box::pin(async move {
            if let Ok(ws) = Workspace::get_active_async().await {
                let msg = WorkspaceMsg {
                    id: Some(ws.id),
                    name: Some(ws.name),
                    screen: Some(ws.monitor),
                };
                if let Err(_) = send_msg(&msg) {
                    eprintln!("Server closed socket. Exiting.");
                    std::process::exit(0);
                }
            }
        })
    });

    listener.start_listener_async().await
}

