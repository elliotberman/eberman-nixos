{ config, lib, ... }:
let
  inherit (config.accounts.email.accounts.elliotjb) enable;
in
{
  programs = {
    mbsync = {
      inherit enable;
    };

    notmuch = {
      inherit enable;

      hooks.postNew = ''
        notmuch tag +anduril -- folder:/anduril/
      '';
    };

    neomutt = {
      inherit enable;

      binds = [
        {
          map = [ "index" ];
          action = "sidebar-prev";
          key = "<left>";
        }
        {
          map = [ "index" ];
          action = "sidebar-next";
          key = "<right>";
        }
        {
          map = [ "index" ];
          action = "sidebar-open";
          key = "<space>";
        }
      ];

      vimKeys = true;

      sidebar = {
        enable = true;
      };

      extraConfig = ''

      '';
    };
  };

  services.mbsync = {
    inherit enable;
    frequency = "00/4:00";
  };

  accounts.email.accounts.elliotjb = {
    address = "elliotjb@elliotjb.com";
    aliases = [
      "elliotjb+anduril@elliotjb.com"
    ];
    realName = "Elliot Berman";
    primary = true;
    enable = lib.mkDefault false;

    mbsync = {
      enable = true;
      create = "maildir";
    };

    notmuch = {
      neomutt = {
        enable = true;
        virtualMailboxes = [
          {
            name = "INBOX";
            query = "tag:inbox";
          }
        ];
      };
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
}
