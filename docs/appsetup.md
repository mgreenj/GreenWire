
# Setting up the Application

Please note that the cross compile setup script was developed to run on Macos.  If you're cross-compiling from a windows machine (i.e. mingw-64), you will have to modify it appropriately.  Below is an example of a change that would be required:

```
# Every instance of `make -j`

# from
make -j$(sysctl -n hw.ncpu)

# to
make -j$(nproc)
```

## Pull the Repository
```
git clone https://github.com/mgreenj/GreenWire.git
```

## Clean Shell Environment
```
env -i bash --noprofile --norc

export HOME=/Users/0x0m03ii
export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin
export TERM=xterm-256color
```

## Run the Cross-Compile setup Script
```
cd GreenWire
chmod +x scripts/setup_crosscompiler.sh
./scripts/setup_crosscompiler.sh
```

## Compile using Cross-compiler Environment Provided
```
cd GreenWire # if not already in GreenWire directory, else skip
make greenwire
```

## Deploy Django Frontend
```
# deploy django
```

# VS Code
If you're using VS Code, be sure to modify the target triple in .vscode/.env