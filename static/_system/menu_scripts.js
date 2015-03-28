
// Remove post
function rm_post(entry_id, id) {
  if (confirm("Remove post?")) { if (confirm("Are you sure?")) {
    xmlhttp = new XMLHttpRequest();
    xmlhttp.open("POST", ("/admin/rm-post/"), true);
    xmlhttp.send('{"id": "' + id + '"}');
    document.getElementById(entry_id).remove();
  }}
}

// Toggle post visiblity
function toggle_post_access(toggle_id, id) {
  xmlhttp = new XMLHttpRequest();
  xmlhttp.open("POST", ("/admin/toggle-post-access/"), true);
  xmlhttp.send('{"id": "' + id + '"}');
  var toggle_link = document.getElementById(toggle_id);
  var toggle = "public";
  if (toggle_link.innerHTML == "public") {toggle = "private"};
  toggle_link.innerHTML = toggle;
}

// Remove file
function rm_file(entry_id, path) {
  if (confirm("Delete, " + path +"?")) { if (confirm("Are you sure?")) {
    xmlhttp = new XMLHttpRequest();
    xmlhttp.open("POST", ("/admin/rm-file/"), true);
    xmlhttp.send('{"path": "' + path + '"}');
    document.getElementById(entry_id).remove();
  }}
}

// Rename file
function rn_file(entry_id, path, old_name) {
  new_name = prompt("New Name:");
  split_by_dot = old_name.split(".");
  old_extension = split_by_dot[split_by_dot.length-1];
  split_by_dot = new_name.split(".");
  new_extension = split_by_dot[split_by_dot.length-1];
  if (old_extension != new_extension) {
    if (!confirm("The new name you provided has a different or missing file extension. Continue?")) {return};
  }		
  xmlhttp = new XMLHttpRequest();
  xmlhttp.open("POST", ("/admin/rn-file/"), true);
  xmlhttp.send('{"path": "' + path + '", "old_name": "' + old_name + '", "new_name": "' + new_name + '"}');
  file_link = document.getElementById(entry_id).getAttribute("href").split("/");
  file_link[file_link.length-1] = new_name.replace(" ", "_");
  document.getElementById(entry_id).setAttribute("href", file_link.join("/"));
  document.getElementById(entry_id).innerHTML = new_name;
}

// New directory (currently reloads page, may change in future)
function new_dir(current_dir) {
  new_dir_name = prompt("Name for new folder:");
  xmlhttp = new XMLHttpRequest();
  xmlhttp.open("POST", ("/admin/new-dir/"), true);
  xmlhttp.send('{"current_dir": "' + current_dir + '", "name": "' + new_dir_name + '"}');
  window.location.href = "/admin/browser/" + current_dir;
}
