state("SonicForever") {}

init
{
    if (modules.First().ModuleMemorySize == 0x3645000) {
        version = "v1.3.4 64bit";
        vars.watchers = new MemoryWatcherList {
            new MemoryWatcher<byte>( new DeepPointer(game.ProcessName + ".exe", 0x5EC2F8 ) ) { Name = "act", Enabled = true },
            new MemoryWatcher<byte>( new DeepPointer(game.ProcessName + ".exe", 0x5EC0B5 ) ) { Name = "zone", Enabled = true },
            new MemoryWatcher<byte>( new DeepPointer(game.ProcessName + ".exe", 0x37D11C ) ) { Name = "state", Enabled = true },
            new MemoryWatcher<ushort>( new DeepPointer(game.ProcessName + ".exe", 0x37FDE2 ) ) { Name = "bossposition", Enabled = true }
        };
    } else if (game.Is64Bit()) {
        version = "v1.3.3 64bit or lower";
        vars.watchers = new MemoryWatcherList {
            new MemoryWatcher<byte>( new DeepPointer(game.ProcessName + ".exe", 0x5E5ED0 ) ) { Name = "act", Enabled = true },
            new MemoryWatcher<byte>( new DeepPointer(game.ProcessName + ".exe", 0x5E5C95 ) ) { Name = "zone", Enabled = true },
            new MemoryWatcher<byte>( new DeepPointer(game.ProcessName + ".exe", 0x376CFC ) ) { Name = "state", Enabled = true },
            new MemoryWatcher<ushort>( new DeepPointer(game.ProcessName + ".exe", 0x3799C2 ) ) { Name = "bossposition", Enabled = true }
        };
    } else if (modules.First().ModuleMemorySize == 0x3623000) {
	    version = "v1.3.4 32bit";
        vars.watchers = new MemoryWatcherList {
            new MemoryWatcher<byte>( new DeepPointer(game.ProcessName + ".exe", 0x7D50F0 ) ) { Name = "act", Enabled = true },
            new MemoryWatcher<byte>( new DeepPointer(game.ProcessName + ".exe", 0x7A2D85 ) ) { Name = "zone", Enabled = true },
            new MemoryWatcher<byte>( new DeepPointer(game.ProcessName + ".exe", 0x50F294 ) ) { Name = "state", Enabled = true },
            new MemoryWatcher<ushort>( new DeepPointer(game.ProcessName + ".exe", 0x511F5A ) ) { Name = "bossposition", Enabled = true }
        };
    } else {
        version = "v1.3.3 32bit or lower";
        vars.watchers = new MemoryWatcherList {
            new MemoryWatcher<byte>( new DeepPointer(game.ProcessName + ".exe", 0x7D43D8 ) ) { Name = "act", Enabled = true },
            new MemoryWatcher<byte>( new DeepPointer(game.ProcessName + ".exe", 0x7A2975 ) ) { Name = "zone", Enabled = true },
            new MemoryWatcher<byte>( new DeepPointer(game.ProcessName + ".exe", 0x48867C ) ) { Name = "state", Enabled = true },
            new MemoryWatcher<ushort>( new DeepPointer(game.ProcessName + ".exe", 0x48B342 ) ) { Name = "bossposition", Enabled = true }
        };
	}
    vars.expectedzone = 0;
    vars.expectedact = 0;
    vars.insaveselect = 0;
}

update {
    vars.watchers.UpdateAll(game);

    if ( vars.watchers["state"].Changed || vars.watchers["zone"].Changed || vars.watchers["act"].Changed  || vars.watchers["bossposition"].Changed ) {
        vars.DebugOutput(String.Format( "State is now: {0}", vars.watchers["state"].Current ));
        if ( vars.watchers["state"].Current == 7 && vars.watchers["state"].Old == 0 ) {
            vars.insaveselect = 1;
        }
        if ( vars.watchers["state"].Current == 100 && vars.watchers["state"].Old == 0 ) {
            vars.insaveselect = 0;
        }
        return true;
    }
    return false;
}


start
{
    if ( 
        vars.insaveselect == 1 &&
        vars.watchers["state"].Changed && (
            ( vars.watchers["state"].Current == 9 && vars.watchers["state"].Old == 8 ) ||
            ( vars.watchers["state"].Current == 7 && vars.watchers["state"].Old == 6 ) ||
            ( vars.watchers["state"].Current == 2 && vars.watchers["state"].Old != 2  )
        )
    ) {
        // GH2
        vars.expectedzone = 49;
        vars.expectedact = 2;
        vars.insaveselect = 0;
        return true;
    }
}

reset
{
    if ( vars.watchers["state"].Changed && vars.watchers["state"].Current == 201 && vars.watchers["state"].Old == 200 ) {
        return true;
    }
}

split
{
    if ( vars.watchers["bossposition"].Changed ) {
        vars.DebugOutput(String.Format("Boss moved {0}", vars.watchers["bossposition"].Current));    
    }
    if ( vars.watchers["act"].Current == 5 && vars.watchers["bossposition"].Changed && vars.watchers["bossposition"].Current > 2450 ) {
        return true;
    }

    if ( !vars.watchers["zone"].Changed && !vars.watchers["act"].Changed ) {
        return;
    }

    vars.DebugOutput(String.Format("Level is now {0}:{1}", vars.watchers["zone"].Current, vars.watchers["act"].Current));
    vars.DebugOutput(String.Format("Exp. Level is {0}:{1}", vars.expectedzone, vars.expectedact));

    // This happens AFTER level switch

    // Zones
    // 49 = GHZ, Acts 1-3
    // 50 = MZ, Acts 1-3
    // 51 = SYZ, Acts 1-3
    // 52 = LBZ, Acts 1-3, Act 4 = SB3
    // 53 = SLZ, Acts 1-3
    // 54 = SBZ, Acts 1-2, Act 5 = FZ
    if ( vars.watchers["zone"].Current == vars.expectedzone && vars.watchers["act"].Current == vars.expectedact ) {
        switch ( (int) vars.watchers["act"].Current ) {
            case 5:
                // credits
                vars.expectedzone = 103;
                vars.expectedact = 1;
                break;
            case 4:
                vars.expectedzone = 54;
                vars.expectedact = 5;
                break;
            case 3:
                vars.expectedzone++;
                vars.expectedact = 1;
                break;
            case 2:
                if ( vars.watchers["zone"].Current == 54 ) {
                    vars.expectedzone = 52;
                    vars.expectedact = 4;
                } else {
                    goto case 1;
                }
                break;
            case 1:
                vars.expectedact++;
                break;
        }
        return true;
    }

}



startup
{
    string logfile = Directory.GetCurrentDirectory() + "\\S1FLogger.log";
    if ( File.Exists( logfile ) ) {
        File.Delete( logfile );
    }
    vars.DebugOutput = (Action<string>)((text) => {
        string time = System.DateTime.Now.ToString("dd/MM/yy hh:mm:ss:fff");
        File.AppendAllText(logfile, "[" + time + "]: " + text + "\r\n");
        print("[S1F] "+text);
    });
}
