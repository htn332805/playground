{ config, lib, ... }:

let cfg = config.programs.pandoc;

in {
  config = lib.mkIf config.test.enableBig {
    programs.pandoc = {
      enable = true;

      defaults = {
        metadata = { author = "John Doe"; };
        pdf-engine = "xelatex";
        citeproc = true;
      };
    };

    nmt.script = ''
      assertFileContent ${cfg.defaultsFile} ${./defaults-expected.json}

      # Test that defaults are set by looking at the metadata for an empty file
      # (it should contain the author that we set in defaults).
      output=$(mktemp)
      ${cfg.finalPackage}/bin/pandoc --standalone \
        -f markdown /dev/null \
        -t native -o "$output"
      assertFileContent "$output" ${./output-expected}
    '';
  };
}

