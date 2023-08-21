from configparser import ConfigParser
from supabase import create_client, Client
from pydantic import BaseModel

parser = ConfigParser()
parser.read("api.config")
supabase: Client = create_client(parser['SUPABASE']['url'], parser['SUPABASE']['key'])

roles_list = ["CC", "OC", "VLT"]
bank_balance_per_role = {"CC": 1000.0, "OC": 1000.0, "VLT": 0.0}
block_list = ["VLT"]

allowed_coupon_to_roles = {"CC": ["high", "mid", "low"], "OC": ["mid", "low"], "VLT": ["low"]}
coupon_types = {"high": 200, "med": 100, "low": 50}

class UserMongoBlueprint(BaseModel):
    email_id: str
    role: str
    supabase_id: str
