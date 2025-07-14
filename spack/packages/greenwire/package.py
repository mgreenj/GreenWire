from spack.package import *


class Greenwire(CMakePackage):
    """GreenWire: A low-latency network application using DPDK, XDP, and custom drivers."""

    homepage = "https://github.com/youruser/greenwire"
    git      = "https://github.com/youruser/greenwire.git"

    maintainers = ['your-github-username']

    version('main', branch='main')

    # Declare dependencies
    depends_on('dpdk')
    depends_on('libbpf')
    depends_on('cmake@3.16:', type='build')

    def cmake_args(self):
        args = []

        # Optional: If you want to customize paths or flags
        # args.append('-DENABLE_SOMETHING=ON')

        return args

    def setup_build_environment(self, env):
        # Optional: You can set custom env vars if needed
        env.set('DPDK_DIR', self.spec['dpdk'].prefix)
        env.set('LIBBPF_DIR', self.spec['libbpf'].prefix)

