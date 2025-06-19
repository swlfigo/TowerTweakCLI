.DEFAULT := build

build:
	swift package purge-cache
	swift package clean
	swift build -c release --arch arm64 --arch x86_64
	cp .build/apple/Products/Release/TowerTweakCLI .

clean:
	swift package purge-cache
	swift package clean
	rm -rf .build TowerTweakCLI