from spack.package import *


class Greenwire(CMakePackage):
    """GreenWire: A low-latency network application using DPDK, XDP, and custom drivers."""

    homepage = "https://github.com/mgreenj/GreenWire"
    git      = "https://github.com/mgreenj/GreenWire.git"

    maintainers = ('mgreenj')

    version('master', branch='master')

    # Declare dependencies
    depends_on('dpdk')
    depends_on('libelf')
    depends_on('cmake@3.16.9', type='build')
    depends_on('pkg-config', type='build')

    def cmake_args(self):
        args = []

        # Optional: If you want to customize paths or flags
        # args.append('-DENABLE_SOMETHING=ON')

        return args

    def setup_build_environment(self, env):
        # Optional: You can set custom env vars if needed
        env.set('DPDK_DIR', self.spec['dpdk'].prefix)
