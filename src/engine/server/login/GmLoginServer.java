// • ▌ ▄ ·.  ▄▄▄·  ▄▄ • ▪   ▄▄· ▄▄▄▄·  ▄▄▄·  ▐▄▄▄  ▄▄▄ .
// ·██ ▐███▪▐█ ▀█ ▐█ ▀ ▪██ ▐█ ▌▪▐█ ▀█▪▐█ ▀█ •█▌ ▐█▐▌·
// ▐█ ▌▐▌▐█·▄█▀▀█ ▄█ ▀█▄▐█·██ ▄▄▐█▀▀█▄▄█▀▀█ ▐█▐ ▐▌▐▀▀▀
// ██ ██▌▐█▌▐█ ▪▐▌▐█▄▪▐█▐█▌▐███▌██▄▪▐█▐█ ▪▐▌██▐ █▌▐█▄▄▌
// ▀▀  █▪▀▀▀ ▀  ▀ ·▀▀▀▀ ▀▀▀·▀▀▀ ·▀▀▀▀  ▀  ▀ ▀▀  █▪ ▀▀▀
//      Magicbane Emulator Project © 2013 - 2022
//                www.magicbane.com

package engine.server.login;

import engine.Enum;
import engine.gameManager.*;
import engine.net.Network;
import engine.net.client.ClientConnectionManager;
import engine.net.client.Protocol;
import engine.net.client.msg.login.VersionInfoMsg;
import engine.objects.*;
import engine.server.MBServerStatics;
import engine.util.ThreadUtils;
import org.pmw.tinylog.Configurator;
import org.pmw.tinylog.Level;
import org.pmw.tinylog.Logger;
import org.pmw.tinylog.labelers.TimestampLabeler;
import org.pmw.tinylog.policies.StartupPolicy;
import org.pmw.tinylog.writers.RollingFileWriter;

import java.io.*;
import java.net.InetAddress;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.time.LocalDateTime;

import static java.lang.System.exit;

public class GmLoginServer extends LoginServer{

    private VersionInfoMsg versionInfoMessage;

    public GmLoginServer() {

    }

    public static void main(String[] args) {

        GmLoginServer gmLoginServer;

        // Initialize TinyLog logger with our own format

        Configurator.defaultConfig()
                .addWriter(new RollingFileWriter("logs/login/gmlogin.txt", 30, new TimestampLabeler(), new StartupPolicy()))
                .level(Level.DEBUG)
                .formatPattern("{level} {date:yyyy-MM-dd HH:mm:ss.SSS} [{thread}] {class}.{method}({line}) : {message}")
                .activate();

        try {

            // Configure the the Login Server

            gmLoginServer = new GmLoginServer();
            ConfigManager.loginServer = gmLoginServer;
            ConfigManager.handler = new LoginServerMsgHandler(gmLoginServer);

            ConfigManager.serverType = Enum.ServerType.LOGINSERVER;

            if (ConfigManager.init() == false) {
                Logger.error("ABORT! Missing config entry!");
                return;
            }

            // Start the Login Server

            gmLoginServer.init();
            gmLoginServer.exec();

            exit(0);

        } catch (Exception e) {
            Logger.error(e);
            e.printStackTrace();
            exit(1);
        }
    }

    private void exec() {


        LocalDateTime nextCacheTime = LocalDateTime.now();
        LocalDateTime nextServerTime = LocalDateTime.now();
        LocalDateTime nextDatabaseTime = LocalDateTime.now();

        loginServerRunning = true;

        while (true) {

            // Invalidate cache for players driven by forum
            // and stored procedure forum_link_pass()

            // Run cache routine right away if requested.

            File cacheFile = new File("gmCacheInvalid");


            if (cacheFile.exists() == true) {

                nextCacheTime = LocalDateTime.now();

                try {
                    Files.deleteIfExists(Paths.get("gmCacheInvalid"));
                } catch (IOException e) {
                    throw new RuntimeException(e);
                }
            }

            if (LocalDateTime.now().isAfter(nextCacheTime)) {
                invalidateCacheList();
                nextCacheTime = LocalDateTime.now().plusSeconds(30);
            }

            if (LocalDateTime.now().isAfter(nextServerTime)) {
                checkServerHealth();
                nextServerTime = LocalDateTime.now().plusSeconds(1);
            }

            if (LocalDateTime.now().isAfter(nextDatabaseTime)) {
                String pop = SimulationManager.getPopulationString();
                Logger.info("Keepalive: " + pop);
                nextDatabaseTime = LocalDateTime.now().plusMinutes(30);
            }

            ThreadUtils.sleep(100);

        }
    }

    private boolean init() {

        // Initialize Application Protocol

        Protocol.initProtocolLookup();

        // Configure the VersionInfoMsgs:

        this.versionInfoMessage = new VersionInfoMsg(ConfigManager.MB_MAJOR_VER.getValue(),
                ConfigManager.MB_MINOR_VER.getValue());

        Logger.info("Initializing Database layer");
        initDatabaseLayer();

        Logger.info("Initializing Network");
        Network.init();

        Logger.info("Initializing Client Connection Manager");
        initClientConnectionManager();

        // instantiate AccountManager
        Logger.info("Initializing SessionManager.");

        // Sets cross server behavior
        SessionManager.setCrossServerBehavior(0);

        // activate powers manager
        Logger.info("Initializing PowersManager.");
        PowersManager.initPowersManager(false);

        RuneBaseAttribute.LoadAllAttributes();
        RuneBase.LoadAllRuneBases();
        BaseClass.LoadAllBaseClasses();
        Race.loadAllRaces();
        RuneBaseEffect.LoadRuneBaseEffects();

        Logger.info("Initializing Blueprint data.");
        Blueprint.loadAllBlueprints();

        Logger.info("Loading Kits");
        DbManager.KitQueries.GET_ALL_KITS();

        Logger.info("Initializing ItemBase data.");
        ItemBase.loadAllItemBases();

        Logger.info("Initializing Race data");
        Enum.RaceType.initRaceTypeTables();
        Race.loadAllRaces();

        Logger.info("Initializing Errant Guild");
        Guild.getErrantGuild();

        Logger.info("Loading All Guilds");
        DbManager.GuildQueries.GET_ALL_GUILDS();


        Logger.info("***Boot Successful***");
        return true;
    }

    private boolean initDatabaseLayer() {

        // Try starting a GOM <-> DB connection.
        try {

            Logger.info("Configuring Magicbane to use Database: '"
                    + ConfigManager.MB_DATABASE_NAME.getValue() + "' on "
                    + ConfigManager.MB_DATABASE_ADDRESS.getValue() + ':'
                    + ConfigManager.MB_DATABASE_PORT.getValue());

            DbManager.configureConnectionPool();

        } catch (Exception e) {
            Logger.error(e.getMessage());
            return false;
        }

        PreparedStatementShared.submitPreparedStatementsCleaningJob();

        if (MBServerStatics.DB_DEBUGGING_ON_BY_DEFAULT) {
            PreparedStatementShared.enableDebugging();
        }

        return true;
    }

    private void initClientConnectionManager() {

        try {

            String name = ConfigManager.MB_WORLD_NAME.getValue();

            ConfigManager.MB_EXTERNAL_ADDR.setValue(ConfigManager.MB_BIND_ADDR.getValue());

            Logger.info("External address: " + ConfigManager.MB_EXTERNAL_ADDR.getValue() + ":" + ConfigManager.MB_LOGIN_PORT.getValue());
            Logger.info("Internal address: " + ConfigManager.MB_BIND_ADDR.getValue() + ":" + ConfigManager.MB_LOGIN_PORT.getValue());

            InetAddress addy = InetAddress.getByName(ConfigManager.MB_BIND_ADDR.getValue());
            int port = Integer.parseInt(ConfigManager.MB_GMLOGIN_PORT.getValue());

            ClientConnectionManager connectionManager = new ClientConnectionManager(name + ".ClientConnMan", addy, port);

            connectionManager.startup();

        } catch (IOException e) {
            Logger.error(e.toString());
        }
    }

    public VersionInfoMsg getDefaultVersionInfo() {
        return versionInfoMessage;
    }

}
