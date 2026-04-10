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
      neomutt.enable = true;
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
