# The git sops clean/smudge filter as a first-class, self-contained package — the SSOT
# shared by BOTH the operator's home-manager git config AND the in-cluster flox render
# env (via rke2lab's flox-catalogue re-export). One derivation, so the filter that
# encrypts `.secrets` on the operator's commit is byte-for-byte the one that decrypts it
# in the aarch64-linux render pod; no re-inlined copy drifts from this definition.
#
# It bakes its OWN store path as `sopsConfigHome`: the top-level `sops` include and every
# per-format fragment resolve the filter/diff commands to the scripts INSIDE this output,
# so a single `include.path = ${this}/sops` wires everything — immutable, location- and
# platform-independent, with no per-file xdg copies at the consumer.
#
# `sops` + `yq` are NOT baked in: they are runtime PATH deps the consumer supplies (the
# operator's home.packages, the flox env's `[install]`), exactly as the dispatcher calls
# them today (bare `sops`/`yq`).
{
  lib,
  stdenvNoCC,
}:
let
  formats = [
    "binary"
    "yaml"
    "json"
    "xml"
    "props"
    "csv"
    "tsv"
    "base64"
    "uri"
    "toml"
    "lua"
  ];
  filters = [
    "clean"
    "smudge"
    "textconv"
  ];
in
stdenvNoCC.mkDerivation {
  name = "git-sops-filter";
  buildCommand = ''
    mkdir -p $out/sops.d

    # The dispatcher, its @sopsConfigHome@ pointed at this output's sops.d.
    substitute ${./sops.sh} $out/sops.sh --subst-var-by sopsConfigHome "$out/sops.d"
    chmod +x $out/sops.sh

    # Per-format git config fragments — filter/diff commands point at the scripts here.
    for fmt in ${lib.concatStringsSep " " formats}; do
      substitute ${./sops.d}/$fmt $out/sops.d/$fmt --subst-var-by sopsConfigHome "$out/sops.d"
    done

    # One dispatcher symlink per (format, op) — sops.sh reads argv[0] for {format, op}.
    for fmt in ${lib.concatStringsSep " " formats}; do
      for op in ${lib.concatStringsSep " " filters}; do
        ln -s $out/sops.sh $out/sops.d/$fmt-$op
      done
    done

    # The top-level include file (relative `path = sops.d/<fmt>`), verbatim.
    cp ${./sops} $out/sops
  '';
}
