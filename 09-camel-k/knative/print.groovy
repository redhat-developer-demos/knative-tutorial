from("knative:channel/sortucase")
  .convertBodyTo(String.class)
  .to("log:info");
