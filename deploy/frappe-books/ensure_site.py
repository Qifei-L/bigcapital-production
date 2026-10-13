import os, json, pathlib, sqlite3, shutil, uuid
root = pathlib.Path("/data/sites")
site = root / os.environ["SITE_NAME"]
config = site / "site_config.json"
if config.exists():
    name = json.loads(config.read_text()).get("db_name")
    db = site / "db" / (str(name) + ".db")
    valid = False
    if db.exists():
        try:
            with sqlite3.connect(db.as_uri() + "?mode=ro", uri=True) as conn:
                valid = bool(conn.execute("select 1 from sqlite_master where type='table' and name='tabDocType'").fetchone())
        except sqlite3.Error:
            pass
    if not valid:
        archive = pathlib.Path("/data/initialization-recovery")
        archive.mkdir(exist_ok=True)
        shutil.move(str(site), str(archive / (site.name + "." + uuid.uuid4().hex)))
        print("Preserved incomplete initialization files; creating a fresh demo site.", flush=True)
