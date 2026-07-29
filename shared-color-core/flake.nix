{
  description = "Shared color — broadcast background color over logos-delivery";

  inputs = {
    logos-module-builder.url = "github:logos-co/logos-module-builder";
    delivery_module.url = "github:logos-co/logos-delivery-module";

    # ── crates.io 403 workaround ──────────────────────────────────────
    # delivery_module → logos-delivery → zerokit vendors its Rust crates
    # with nixpkgs' fetchCargoVendor. Until 2026-06-22 that helper sent no
    # User-Agent and downloaded via crates.io/api/v1; crates.io now answers
    # 403 to such requests, so the vendor step — and with it every module
    # depending on delivery_module — fails to build.
    #
    # nixpkgs 2a0e0bae ("rustPlatform.fetchCargoVendor: remove duplicate
    # fetcher") adds the User-Agent and moves downloads to static.crates.io.
    # logos-delivery pins nixpkgs at 535f3e69 (2026-06-03), three weeks
    # short of it, so we redirect just that node. zerokit already declares
    # `nixpkgs.follows = ["delivery_module" "logos-delivery" "nixpkgs"]`,
    # so this single override reaches the failing derivation.
    #
    # Remove once logos-delivery advances its own nixpkgs pin past
    # 2026-06-22 — this exists only to unblock the build.
    nixpkgs-vendor-fix.url = "github:NixOS/nixpkgs/2a0e0baec1c99cdc087c14f83ac6c31c929d14eb";
    delivery_module.inputs.logos-delivery.inputs.nixpkgs.follows = "nixpkgs-vendor-fix";
  };

  outputs = inputs@{ logos-module-builder, ... }:
    logos-module-builder.lib.mkLogosModule {
      src = ./.;
      configFile = ./metadata.json;
      flakeInputs = inputs;
    };
}
