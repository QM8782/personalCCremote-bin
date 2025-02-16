if not fs.exists("/.connectTool/main.lua") then
	print("Please follow the instructions on the installer.")
	sleep(5)
	while not fs.exists("/.connectTool/main.lua") do
		shell.run("wget run https://raw.githubusercontent.com/QM8782/personalCCremote-bin/refs/heads/main/installer.lua")
	end
	shell.execute("/.connectTool/main.lua")
else
	shell.execute("/.connectTool/main.lua")
end
