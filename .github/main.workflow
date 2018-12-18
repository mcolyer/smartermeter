workflow "Run tests" {
  on = "push"
  resolves = ["docker://ruby"]
}

action "docker://ruby" {
  uses = "docker://ruby"
  runs = "ruby"
  args = "-v"
}
