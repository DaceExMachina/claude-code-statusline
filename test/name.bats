#!/usr/bin/env bats

load 'helpers'

@test "name: leads line 1 with the name from the matching registry file" {
  make_registry "other-session" decoy 0
  make_registry "$TEST_SID" extension-69 1
  run run_sl
  [ "$(plain)" = "# extension-69  ✦ Opus 4.6  █░░░░ 25%" ]
}

@test "name: reads the registry fresh on every run" {
  make_registry "$TEST_SID" extension-69
  run run_sl
  [ "$(plain)" = "# extension-69  ✦ Opus 4.6  █░░░░ 25%" ]
  make_registry "$TEST_SID" renamed
  run run_sl
  [ "$(plain)" = "# renamed  ✦ Opus 4.6  █░░░░ 25%" ]
}

@test "name: no matching registry file shows nothing" {
  make_registry "other-session" decoy
  run run_sl
  [ "$status" -eq 0 ]
  [ "$(plain)" = "✦ Opus 4.6  █░░░░ 25%" ]
}

@test "name: missing registry directory shows nothing" {
  CLAUDE_CONFIG_DIR="$BATS_TEST_TMPDIR/none" run run_sl
  [ "$status" -eq 0 ]
  [ "$(plain)" = "✦ Opus 4.6  █░░░░ 25%" ]
}

@test "name: the most recently modified registry file wins for a shared session id" {
  make_registry "$TEST_SID" stale 1
  make_registry "$TEST_SID" resumed 2
  touch -t 202001010000 "$CLAUDE_CONFIG_DIR/sessions/1.json"
  run run_sl
  [ "$(plain)" = "# resumed  ✦ Opus 4.6  █░░░░ 25%" ]
  touch -t 202001010000 "$CLAUDE_CONFIG_DIR/sessions/2.json"
  touch -t 202101010000 "$CLAUDE_CONFIG_DIR/sessions/1.json"
  run run_sl
  [ "$(plain)" = "# stale  ✦ Opus 4.6  █░░░░ 25%" ]
}
