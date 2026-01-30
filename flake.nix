{
  description = "ScottyLabs shared devenv configuration";

  outputs = { self }: {
    devenvModules.default = import ./modules;
  };
}
