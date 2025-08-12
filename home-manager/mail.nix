{ config, lib, ... }:
{
  options.eberman.email.passwordCommand = lib.mkOption {
    default = null;
    type = with lib.types; nullOr str;
  };

  config = lib.mkIf (config.eberman.email.passwordCommand != null) {
    programs = {
      mbsync = {
        enable = true;
      };

      notmuch = {
        enable = true;
      };

      neomutt = {
        enable = true;
      };
    };

    accounts.email.accounts.elliotjb = {
      address = "elliotjb@elliotjb.com";
      aliases = [
        "elliotjb+anduril@elliotjb.com"
      ];
      realName = "Elliot Berman";
      primary = true;
      inherit (config.eberman.email) passwordCommand;

      mbsync = {
        enable = true;
      };

      notmuch = {
        enable = true;
      };

      neomutt = {
        enable = true;
      };

      userName = "elliotjb@elliotjb.com";
      imap = {
        host = "mail.privateemail.com";
        port = 993;
        tls.enable = true;
      };

      smtp = {
        host = "mail.privateemail.com";
        port = 465;
        tls.enable = true;
      };
    };
  };
}
