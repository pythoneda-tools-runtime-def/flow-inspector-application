# flake.nix
#
# This file packages pythoneda-tools-runtime/flow-inspector-application as a Nix flake.
#
# Copyright (C) 2024-today rydnr's pythoneda-tools-runtime/flow-inspector-application
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
{
  description = "Nix flake for pythoneda-tools-runtime/flow-inspector-application";
  inputs = rec {
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    nixpkgs.url = "github:NixOS/nixpkgs/24.05";
    pythoneda-shared-pythonlang-application = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pythoneda-shared-pythonlang-banner.follows =
        "pythoneda-shared-pythonlang-banner";
      url = "github:pythoneda-shared-pythonlang-def/application/0.0.119";
    };
    pythoneda-shared-pythonlang-banner = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:pythoneda-shared-pythonlang-def/banner/0.0.83";
    };
    pythoneda-shared-pythonlang-domain = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pythoneda-shared-pythonlang-banner.follows =
        "pythoneda-shared-pythonlang-banner";
      url = "github:pythoneda-shared-pythonlang-def/domain/0.0.126";
    };
    pythoneda-tools-runtime-flow-inspector = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pythoneda-shared-pythonlang-banner.follows =
        "pythoneda-shared-pythonlang-banner";
      inputs.pythoneda-shared-pythonlang-domain.follows =
        "pythoneda-shared-pythonlang-domain";
      url = "github:pythoneda-tools-runtime-def/flow-inspector/0.0.14";
    };
    pythoneda-tools-runtime-flow-inspector-infrastructure = {
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pythoneda-shared-pythonlang-banner.follows =
        "pythoneda-shared-pythonlang-banner";
      inputs.pythoneda-shared-pythonlang-domain.follows =
        "pythoneda-shared-pythonlang-domain";
      inputs.pythoneda-tools-runtime-flow-inspector.follows =
        "pythoneda-tools-runtime-flow-inspector";
      url = "github:pythoneda-tools-runtime-def/flow-inspector-infrastructure/0.0.15";
    };
  };
  outputs = inputs:
    with inputs;
    let
      defaultSystems = flake-utils.lib.defaultSystems;
      supportedSystems = if builtins.elem "armv6l-linux" defaultSystems then
        defaultSystems
      else
        defaultSystems ++ [ "armv6l-linux" ];
    in flake-utils.lib.eachSystem supportedSystems (system:
      let
        org = "pythoneda-tools-runtime";
        repo = "flow-inspector-application";
        version = "0.0.3";
        sha256 = "0lzfwmdd29hjd1g8j5shpydhcw6qmnvrcyahxjn2f0mx4spy2bx2";
        pname = "${org}-${repo}";
        pythonpackage = "pythoneda.tools.runtime.flow_inspector.application";
        package = builtins.replaceStrings [ "." ] [ "/" ] pythonpackage;
        entrypoint = "flow_inspector_app";
        description = "Application layer for pythoneda-tools-runtime/flow-inspector";
        license = pkgs.lib.licenses.gpl3;
        homepage = "https://github.com/pythoneda-tools-runtime/flow-inspector-application";
        maintainers = [ "rydnr <github@acm-sl.org>" ];
        archRole = "B";
        space = "R";
        layer = "A";
        nixpkgsVersion = builtins.readFile "${nixpkgs}/.version";
        nixpkgsRelease =
          builtins.replaceStrings [ "\n" ] [ "" ] "nixpkgs-${nixpkgsVersion}";
        shared = import "${pythoneda-shared-pythonlang-banner}/nix/shared.nix";
        pkgs = import nixpkgs { inherit system; };
        pythoneda-tools-runtime-flow-inspector-application-for = { python
          , pythoneda-shared-pythonlang-application
          , pythoneda-shared-pythonlang-banner
          , pythoneda-shared-pythonlang-domain
          , pythoneda-tools-runtime-flow-inspector
          , pythoneda-tools-runtime-flow-inspector-infrastructure}:
          let
            pnameWithUnderscores =
              builtins.replaceStrings [ "-" ] [ "_" ] pname;
            pythonVersionParts = builtins.splitVersion python.version;
            pythonMajorVersion = builtins.head pythonVersionParts;
            pythonMajorMinorVersion =
              "${pythonMajorVersion}.${builtins.elemAt pythonVersionParts 1}";
            wheelName =
              "${pnameWithUnderscores}-${version}-py${pythonMajorVersion}-none-any.whl";
            banner_file = "${package}/flow_inspector_banner.py";
            banner_class = "FlowInspectorBanner";
          in python.pkgs.buildPythonPackage rec {
            inherit pname version;
            projectDir = ./.;
            pyprojectTomlTemplate = ./templates/pyproject.toml.template;
            pyprojectToml = pkgs.substituteAll {
              authors = builtins.concatStringsSep ","
                (map (item: ''"${item}"'') maintainers);
              desc = description;
              inherit homepage pname pythonMajorMinorVersion package
                version;
              pythonedaSharedPythonlangApplication =
                pythoneda-shared-pythonlang-application.version;
              pythonedaSharedPythonlangDomain =
                pythoneda-shared-pythonlang-domain.version;
              pythonedaToolsRuntimeFlowInspector =
                pythoneda-tools-runtime-flow-inspector.version;
              pythonedaToolsRuntimeFlowInspectorInfrastructure =
                pythoneda-tools-runtime-flow-inspector-infrastructure.version;
              src = pyprojectTomlTemplate;
            };
            bannerTemplateFile =
              "${pythoneda-shared-pythonlang-banner}/templates/banner.py.template";
            bannerTemplate = pkgs.substituteAll {
              project_name = pname;
              file_path = banner_file;
              inherit banner_class org repo;
              tag = version;
              pescio_space = space;
              arch_role = archRole;
              hexagonal_layer = layer;
              python_version = pythonMajorMinorVersion;
              nixpkgs_release = nixpkgsRelease;
              src = bannerTemplateFile;
            };

            entrypointTemplateFile =
              "${pythoneda-shared-pythonlang-banner}/templates/entrypoint.sh.template";
            entrypointTemplate = pkgs.substituteAll {
              arch_role = archRole;
              hexagonal_layer = layer;
              nixpkgs_release = nixpkgsRelease;
              inherit homepage maintainers org python repo version;
              pescio_space = space;
              python_version = pythonMajorMinorVersion;
              pythoneda_shared_banner = pythoneda-shared-pythonlang-banner;
              pythoneda_shared_domain = pythoneda-shared-pythonlang-domain;
              src = entrypointTemplateFile;
            };
            src = pkgs.fetchFromGitHub {
              owner = org;
              rev = version;
              inherit repo sha256;
            };

            format = "pyproject";

            nativeBuildInputs = with python.pkgs; [ pip poetry-core ];
            propagatedBuildInputs = with python.pkgs; [
              pythoneda-shared-pythonlang-application
              pythoneda-shared-pythonlang-domain
              pythoneda-tools-runtime-flow-inspector
              pythoneda-tools-runtime-flow-inspector-infrastructure
            ];

            # pythonImportsCheck = [ pythonpackage ];

            unpackPhase = ''
              command cp -r ${src}/* .
              command chmod -R +w .
              command cp ${pyprojectToml} ./pyproject.toml
              command cp ${bannerTemplate} ./${banner_file}
              command cp ${entrypointTemplate} ./entrypoint.sh
            '';

            postPatch = ''
              substituteInPlace ./entrypoint.sh \
                --replace "@SOURCE@" "$out/bin/${entrypoint}.sh" \
                --replace "@PYTHONPATH@" "$PYTHONPATH:$out/lib/python${pythonMajorMinorVersion}/site-packages" \
                --replace "@CUSTOM_CONTENT@" "" \
                --replace "@ENTRYPOINT@" "$out/lib/python${pythonMajorMinorVersion}/site-packages/${package}/application/${entrypoint}.py" \
                --replace "@BANNER@" "$out/bin/banner.sh"
            '';

            postInstall = with python.pkgs; ''
              for f in $(command find . -name '__init__.py'); do
                if [[ ! -e $out/lib/python${pythonMajorMinorVersion}/site-packages/$f ]]; then
                  command cp $f $out/lib/python${pythonMajorMinorVersion}/site-packages/$f;
                fi
              done
              command mkdir -p $out/bin $out/dist $out/deps/flakes $out/deps/nixpkgs
              command cp dist/${wheelName} $out/dist
              command cp ./entrypoint.sh $out/bin/${entrypoint}.sh
              command chmod +x $out/bin/${entrypoint}.sh
              command echo '#!/usr/bin/env sh' > $out/bin/banner.sh
              command echo "export PYTHONPATH=$PYTHONPATH" >> $out/bin/banner.sh
              command echo "${python}/bin/python $out/lib/python${pythonMajorMinorVersion}/site-packages/${banner_file} \$@" >> $out/bin/banner.sh
              command chmod +x $out/bin/banner.sh
              for dep in ${pythoneda-shared-pythonlang-application} ${pythoneda-shared-pythonlang-domain} ${pythoneda-tools-runtime-flow-inspector} ${pythoneda-tools-runtime-flow-inspector-infrastructure}; do
                command cp -r $dep/dist/* $out/deps || true
                if [ -e $dep/deps ]; then
                  command cp -r $dep/deps/* $out/deps || true
                fi
                METADATA=$dep/lib/python${pythonMajorMinorVersion}/site-packages/*.dist-info/METADATA
                NAME="$(command grep -m 1 '^Name: ' $METADATA | command cut -d ' ' -f 2)"
                VERSION="$(command grep -m 1 '^Version: ' $METADATA | command cut -d ' ' -f 2)"
                command ln -s $dep $out/deps/flakes/$NAME-$VERSION || true
              done
            '';

            meta = with pkgs.lib; {
              inherit description homepage license maintainers;
            };
          };
      in rec {
        apps = rec {
          default = pythoneda-tools-runtime-flow-inspector-application-python312;
          pythoneda-tools-runtime-flow-inspector-application-python39 = shared.app-for {
            package =
              self.packages.${system}.pythoneda-tools-runtime-flow-inspector-application-python39;
            inherit entrypoint;
          };
          pythoneda-tools-runtime-flow-inspector-application-python310 = shared.app-for {
            package =
              self.packages.${system}.pythoneda-tools-runtime-flow-inspector-application-python310;
            inherit entrypoint;
          };
          pythoneda-tools-runtime-flow-inspector-application-python311 = shared.app-for {
            package =
              self.packages.${system}.pythoneda-tools-runtime-flow-inspector-application-python311;
            inherit entrypoint;
          };
          pythoneda-tools-runtime-flow-inspector-application-python312 = shared.app-for {
            package =
              self.packages.${system}.pythoneda-tools-runtime-flow-inspector-application-python312;
            inherit entrypoint;
          };
          pythoneda-tools-runtime-flow-inspector-application-python313 = shared.app-for {
            package =
              self.packages.${system}.pythoneda-tools-runtime-flow-inspector-application-python313;
            inherit entrypoint;
          };
        };
        defaultApp = apps.default;
        defaultPackage = packages.default;
        devShells = rec {
          default = pythoneda-tools-runtime-flow-inspector-application-python312;
          pythoneda-tools-runtime-flow-inspector-application-python39 = shared.devShell-for {
            banner = "${
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python39
              }/bin/banner.sh";
            extra-namespaces = "";
            nixpkgs-release = nixpkgsRelease;
            package = packages.pythoneda-tools-runtime-flow-inspector-application-python39;
            python = pkgs.python39;
            pythoneda-shared-pythonlang-banner =
              pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python39;
            pythoneda-shared-pythonlang-domain =
              pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python39;
            inherit archRole layer org pkgs repo space;
          };
          pythoneda-tools-runtime-flow-inspector-application-python310 = shared.devShell-for {
            banner = "${
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python310
              }/bin/banner.sh";
            extra-namespaces = "";
            nixpkgs-release = nixpkgsRelease;
            package = packages.pythoneda-tools-runtime-flow-inspector-application-python310;
            python = pkgs.python310;
            pythoneda-shared-pythonlang-banner =
              pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python310;
            pythoneda-shared-pythonlang-domain =
              pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python310;
            inherit archRole layer org pkgs repo space;
          };
          pythoneda-tools-runtime-flow-inspector-application-python311 = shared.devShell-for {
            banner = "${
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python311
              }/bin/banner.sh";
            extra-namespaces = "";
            nixpkgs-release = nixpkgsRelease;
            package = packages.pythoneda-tools-runtime-flow-inspector-application-python311;
            python = pkgs.python311;
            pythoneda-shared-pythonlang-banner =
              pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python311;
            pythoneda-shared-pythonlang-domain =
              pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python311;
            inherit archRole layer org pkgs repo space;
          };
          pythoneda-tools-runtime-flow-inspector-application-python312 = shared.devShell-for {
            banner = "${
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python312
              }/bin/banner.sh";
            extra-namespaces = "";
            nixpkgs-release = nixpkgsRelease;
            package = packages.pythoneda-tools-runtime-flow-inspector-application-python312;
            python = pkgs.python312;
            pythoneda-shared-pythonlang-banner =
              pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python312;
            pythoneda-shared-pythonlang-domain =
              pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python312;
            inherit archRole layer org pkgs repo space;
          };
          pythoneda-tools-runtime-flow-inspector-application-python313 = shared.devShell-for {
            banner = "${
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python313
              }/bin/banner.sh";
            extra-namespaces = "";
            nixpkgs-release = nixpkgsRelease;
            package = packages.pythoneda-tools-runtime-flow-inspector-application-python313;
            python = pkgs.python313;
            pythoneda-shared-pythonlang-banner =
              pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python313;
            pythoneda-shared-pythonlang-domain =
              pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python313;
            inherit archRole layer org pkgs repo space;
          };
        };
        packages = rec {
          default = pythoneda-tools-runtime-flow-inspector-application-python312;
          pythoneda-tools-runtime-flow-inspector-application-python39 =
            pythoneda-tools-runtime-flow-inspector-application-for {
              python = pkgs.python39;
              pythoneda-shared-pythonlang-application =
                pythoneda-shared-pythonlang-application.packages.${system}.pythoneda-shared-pythonlang-application-python39;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python39;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python39;
              pythoneda-tools-runtime-flow-inspector =
                pythoneda-tools-runtime-flow-inspector.packages.${system}.pythoneda-tools-runtime-flow-inspector-python39;
              pythoneda-tools-runtime-flow-inspector-infrastructure =
                pythoneda-tools-runtime-flow-inspector-infrastructure.packages.${system}.pythoneda-tools-runtime-flow-inspector-infrastructure-python39;
            };
          pythoneda-tools-runtime-flow-inspector-application-python310 =
            pythoneda-tools-runtime-flow-inspector-application-for {
              python = pkgs.python310;
              pythoneda-shared-pythonlang-application =
                pythoneda-shared-pythonlang-application.packages.${system}.pythoneda-shared-pythonlang-application-python310;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python310;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python310;
              pythoneda-tools-runtime-flow-inspector =
                pythoneda-tools-runtime-flow-inspector.packages.${system}.pythoneda-tools-runtime-flow-inspector-python310;
              pythoneda-tools-runtime-flow-inspector-infrastructure =
                pythoneda-tools-runtime-flow-inspector-infrastructure.packages.${system}.pythoneda-tools-runtime-flow-inspector-infrastructure-python310;
            };
          pythoneda-tools-runtime-flow-inspector-application-python311 =
            pythoneda-tools-runtime-flow-inspector-application-for {
              python = pkgs.python311;
              pythoneda-shared-pythonlang-application =
                pythoneda-shared-pythonlang-application.packages.${system}.pythoneda-shared-pythonlang-application-python311;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python311;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python311;
              pythoneda-tools-runtime-flow-inspector =
                pythoneda-tools-runtime-flow-inspector.packages.${system}.pythoneda-tools-runtime-flow-inspector-python311;
              pythoneda-tools-runtime-flow-inspector-infrastructure =
                pythoneda-tools-runtime-flow-inspector-infrastructure.packages.${system}.pythoneda-tools-runtime-flow-inspector-infrastructure-python311;
            };
          pythoneda-tools-runtime-flow-inspector-application-python312 =
            pythoneda-tools-runtime-flow-inspector-application-for {
              python = pkgs.python312;
              pythoneda-shared-pythonlang-application =
                pythoneda-shared-pythonlang-application.packages.${system}.pythoneda-shared-pythonlang-application-python312;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python312;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python312;
              pythoneda-tools-runtime-flow-inspector =
                pythoneda-tools-runtime-flow-inspector.packages.${system}.pythoneda-tools-runtime-flow-inspector-python312;
              pythoneda-tools-runtime-flow-inspector-infrastructure =
                pythoneda-tools-runtime-flow-inspector-infrastructure.packages.${system}.pythoneda-tools-runtime-flow-inspector-infrastructure-python312;
            };
          pythoneda-tools-runtime-flow-inspector-application-python313 =
            pythoneda-tools-runtime-flow-inspector-application-for {
              python = pkgs.python313;
              pythoneda-shared-pythonlang-application =
                pythoneda-shared-pythonlang-application.packages.${system}.pythoneda-shared-pythonlang-application-python313;
              pythoneda-shared-pythonlang-banner =
                pythoneda-shared-pythonlang-banner.packages.${system}.pythoneda-shared-pythonlang-banner-python313;
              pythoneda-shared-pythonlang-domain =
                pythoneda-shared-pythonlang-domain.packages.${system}.pythoneda-shared-pythonlang-domain-python313;
              pythoneda-tools-runtime-flow-inspector =
                pythoneda-tools-runtime-flow-inspector.packages.${system}.pythoneda-tools-runtime-flow-inspector-python313;
              pythoneda-tools-runtime-flow-inspector-infrastructure =
                pythoneda-tools-runtime-flow-inspector-infrastructure.packages.${system}.pythoneda-tools-runtime-flow-inspector-infrastructure-python313;
            };
        };
      });
}
