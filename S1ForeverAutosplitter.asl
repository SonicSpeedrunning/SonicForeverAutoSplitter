state("SonicForever") {}

init
{
    vars.watchers = new MemoryWatcherList();
    var scanner = new SignatureScanner(game, modules.First().BaseAddress, modules.First().ModuleMemorySize);
    IntPtr ptr = IntPtr.Zero;

	switch (game.Is64Bit()) {
			case true: 
				switch (modules.First().ModuleMemorySize) {
					default: // For 1.3.4 and over
						ptr = scanner.Scan(new SigScanTarget(3,
							"48 63 05 ????????",   // movsxd rax,dword ptr [SonicForever.exe+7C6C74]  <----
							"48 C1 E1 08"));       // shl rcx,08
						if (ptr == IntPtr.Zero) throw new Exception("Could not find address!");
						vars.watchers.Add(new MemoryWatcher<byte>(new DeepPointer(ptr + 4 + game.ReadValue<int>(ptr))) { Name = "LevelID" });
						
						ptr = scanner.Scan(new SigScanTarget(2,
							"8B 0D ????????",     // mov ecx,[SonicForever.exe+5EC0A8]  <----
							"74 59"));            // je SonicForever.exe+30648
						if (ptr == IntPtr.Zero) throw new Exception("Could not find address!");
						vars.watchers.Add(new MemoryWatcher<uint>(new DeepPointer(ptr + 4 +  game.ReadValue<int>(ptr) + 0x8)) { Name = "ZoneIndicator" }); 

						ptr = scanner.Scan(new SigScanTarget(3,
							"4C 8D 25 ????????",  // lea r12,[SonicForever.exe+37C730]   <----
							"44 8B 35 ????????",  // mov r14d,[SonicForever.exe+E07A94]
							"33 DB"));            // xor ebx,ebx
						if (ptr == IntPtr.Zero) throw new Exception("Could not find address!");
						vars.watchers.Add(new MemoryWatcher<byte>(new DeepPointer(ptr + 4 +  game.ReadValue<int>(ptr) + 0x9D8 + 0x14)) { Name = "State" }); 
						vars.watchers.Add(new MemoryWatcher<ushort>(new DeepPointer(ptr + 4 +  game.ReadValue<int>(ptr) + 0x9D8 + 0x14 + 0x2CC6)) { Name = "BossPosition" });
						
						ptr = scanner.Scan(new SigScanTarget(2,
							"89 05 ????????",   // mov [SonicForever.exe+5EC1BC],eax  <----
							"83 F8 3B"));       // cmp eax,3B
						if (ptr == IntPtr.Zero) throw new Exception("Could not find address!");
						vars.watchers.Add(new MemoryWatcher<byte>(new DeepPointer(ptr + 4 +  game.ReadValue<int>(ptr))) { Name = "Minutes" }); 
						
						ptr = scanner.Scan(new SigScanTarget(2,
							"89 05 ????????",    // mov [SonicForever.exe+5EC2EC],eax  <----
							"8B CA"));           // mov ecx,edx
						if (ptr == IntPtr.Zero) throw new Exception("Could not find address!");
						vars.watchers.Add(new MemoryWatcher<byte>(new DeepPointer(ptr + 4 +  game.ReadValue<int>(ptr))) { Name = "Secs" }); 

						ptr = scanner.Scan(new SigScanTarget(4,
							"03 D0",             // add edx,eax
							"89 15 ????????"));  // mov [SonicForever.exe+5EC1B8],eax  <----
						if (ptr == IntPtr.Zero) throw new Exception("Could not find address!");
						vars.watchers.Add(new MemoryWatcher<byte>(new DeepPointer(ptr + 4 +  game.ReadValue<int>(ptr))) { Name = "Centisecs" });
						break;
					case 0x364B000:   // 1.2.1 64bit and below
						vars.watchers.Add(new MemoryWatcher<byte>(new DeepPointer(modules.First().BaseAddress + 0x79E04C)) { Name = "LevelID" }); 
						vars.watchers.Add(new MemoryWatcher<uint>(new DeepPointer(modules.First().BaseAddress + 0x5E5C90)) { Name = "ZoneIndicator" });
						vars.watchers.Add(new MemoryWatcher<byte>(new DeepPointer(modules.First().BaseAddress + 0x376CFC)) { Name = "State" }); 
						vars.watchers.Add(new MemoryWatcher<ushort>(new DeepPointer(modules.First().BaseAddress + 0x3799C2)) { Name = "BossPosition" });
						vars.watchers.Add(new MemoryWatcher<byte>(new DeepPointer(modules.First().BaseAddress + 0x5E5D94)) { Name = "Minutes" }); 
						vars.watchers.Add(new MemoryWatcher<byte>(new DeepPointer(modules.First().BaseAddress + 0x5E5EC4)) { Name = "Secs" }); 
						vars.watchers.Add(new MemoryWatcher<byte>(new DeepPointer(modules.First().BaseAddress + 0x5E5D90)) { Name = "Centisecs" }); 
						break;
				}
				break;
				
			case false:
				switch (modules.First().ModuleMemorySize) {
					default:  // For 1.3.4 and over
						ptr = scanner.Scan(new SigScanTarget(2,
							"03 05 ????????",         // add eax,[SonicForever.exe+BF4E6C]
							"69 C8 C1000000"));       // imul ecx,eax,000000C1
						if (ptr == IntPtr.Zero) throw new Exception("Could not find address!");
						vars.watchers.Add(new MemoryWatcher<byte>(new DeepPointer((IntPtr)game.ReadValue<int>(ptr))) { Name = "LevelID" }); 
						vars.watchers.Add(new MemoryWatcher<uint>(new DeepPointer((IntPtr)game.ReadValue<int>(ptr) + 4)) { Name = "ZoneIndicator" }); 

						ptr = scanner.Scan(new SigScanTarget(2,
							"8B 80 ????????",      // mov eax,[eax+SonicForever.exe+90FAAC]
							"89 04 95 ????????",   // mov [edx*4+SonicForever.exe+1234F00],eax
							"E9 070E0000"));       // jmp SonicForever.exe+2AAA6
						if (ptr == IntPtr.Zero) throw new Exception("Could not find address!");
						vars.watchers.Add(new MemoryWatcher<byte>(new DeepPointer((IntPtr)game.ReadValue<int>(ptr) + 0x9D8)) { Name = "State" }); 
						vars.watchers.Add(new MemoryWatcher<ushort>(new DeepPointer((IntPtr)game.ReadValue<int>(ptr) + 0x9D8 + 0x2CC6)) { Name = "BossPosition" });
						
						ptr = scanner.Scan(new SigScanTarget(6,
							"E9 37090000",         // jmp SonicForever.exe+2AAA6
							"A1 ????????"));       // mov eax,[SonicForever.exe+C271D4]
						if (ptr == IntPtr.Zero) throw new Exception("Could not find address!");
						vars.watchers.Add(new MemoryWatcher<byte>(new DeepPointer((IntPtr)game.ReadValue<int>(ptr))) { Name = "Minutes" }); 
						
						ptr = scanner.Scan(new SigScanTarget(6,
							"E9 48090000",         // jmp SonicForever.exe+2AAA6
							"A1 ????????"));       // mov eax,[SonicForever.exe+C271D4]
						if (ptr == IntPtr.Zero) throw new Exception("Could not find address!");
						vars.watchers.Add(new MemoryWatcher<byte>(new DeepPointer((IntPtr)game.ReadValue<int>(ptr))) { Name = "Secs" }); 

						ptr = scanner.Scan(new SigScanTarget(6,
							"E9 59090000",         // jmp SonicForever.exe+2AAA6
							"A1 ????????"));       // mov eax,[SonicForever.exe+C2539C]
						if (ptr == IntPtr.Zero) throw new Exception("Could not find address!");
						vars.watchers.Add(new MemoryWatcher<byte>(new DeepPointer((IntPtr)game.ReadValue<int>(ptr))) { Name = "Centisecs" }); 
						break;
					case 0x362B000: // 1.2.1 32bit and below
						vars.watchers.Add(new MemoryWatcher<byte>(new DeepPointer(modules.First().BaseAddress + 0x5C7FEC)) { Name = "LevelID" }); 
						vars.watchers.Add(new MemoryWatcher<uint>(new DeepPointer(modules.First().BaseAddress + 0x7A2970)) { Name = "ZoneIndicator" }); 
						vars.watchers.Add(new MemoryWatcher<byte>(new DeepPointer(modules.First().BaseAddress + 0x48867C)) { Name = "State" }); 
						vars.watchers.Add(new MemoryWatcher<ushort>(new DeepPointer(modules.First().BaseAddress + 0x48B342)) { Name = "BossPosition" });
						vars.watchers.Add(new MemoryWatcher<byte>(new DeepPointer(modules.First().BaseAddress + 0x7D2E98)) { Name = "Minutes" }); 
						vars.watchers.Add(new MemoryWatcher<byte>(new DeepPointer(modules.First().BaseAddress + 0x7D43CC)) { Name = "Secs" }); 
						vars.watchers.Add(new MemoryWatcher<byte>(new DeepPointer(modules.First().BaseAddress + 0x7D2E94)) { Name = "Centisecs" }); 
						break;
				}
				break;
	}

	vars.MenuItem = "";
    current.LevelID = 0;
	vars.AccumulatedIGT = 0d;
}

update {
    vars.watchers.UpdateAll(game);
	if (timer.CurrentPhase == TimerPhase.NotRunning) vars.AccumulatedIGT = 0;		
		
	switch ((uint)vars.watchers["ZoneIndicator"].Current) {
		case 0x6E69614D:
		    vars.MenuItem = "MainMenu";
			break;
		case 0x65766153:
			vars.MenuItem = "SaveSelect";
			break;
		case 0x656E6F5A:
		    vars.MenuItem = "Zones";
			break;
		case 0x63657053:
		    vars.MenuItem = "SpecialStages";
			break;
	}
	
	if (vars.MenuItem == "Zones") current.LevelID = vars.watchers["LevelID"].Current;
	
	current.GameTimer = vars.watchers["Minutes"].Current * 60 + vars.watchers["Secs"].Current + (double)vars.watchers["Centisecs"].Current / 100;
	if (current.GameTimer == 0 && old.GameTimer > 0) vars.AccumulatedIGT += old.GameTimer;
}


start
{
    return(vars.MenuItem == "SaveSelect" &&
            vars.watchers["State"].Changed && (
            ( vars.watchers["State"].Current == 9 && vars.watchers["State"].Old == 8 ) ||
            ( vars.watchers["State"].Current == 7 && vars.watchers["State"].Old == 6 ) ||
            ( vars.watchers["State"].Current == 2 && vars.watchers["State"].Old != 2  ))
	);
}

reset
{
    return vars.watchers["State"].Current == 201 && vars.watchers["State"].Old == 200 && vars.MenuItem == "SaveSelect";
}

split
{
    if (current.LevelID == 18 && vars.watchers["BossPosition"].Changed && vars.watchers["BossPosition"].Current > 2450 ) {
        return true;
    }

    if (current.LevelID == old.LevelID) return;
    if (current.LevelID == old.LevelID + 1 && vars.MenuItem == "Zones") return true;
}

gameTime
{
	return TimeSpan.FromSeconds(vars.AccumulatedIGT + current.GameTimer);
}

isLoading
{
	return true;
}
