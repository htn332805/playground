{ pkgs ? import <nixpkgs> {} }:

pkgs.nixosTest {
  name = "hello-counter-test";

  nodes.machine = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.python3 ];
  };

  testScript = ''
    import time

    start_all()
    machine.wait_for_unit("multi-user.target")

    cnt = 0
    start_time = time.time()
    end_time = start_time + 3 * 3600  # 3 hours

    while time.time() < end_time:
        machine.succeed(f"python3 -c 'print(\"hello {cnt}\")'")
        cnt += 1
        time.sleep(5)

    print(f"Final count: {cnt}")
  '';
}
