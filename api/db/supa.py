from supabase import Client, PostgrestAPIResponse
from global_var import UserMongoBlueprint, parser
from postgrest import exceptions
from fastapi import HTTPException
import jwt


class Supa:
    def __init__(self, supabase: Client) -> None:
        self.supabase = supabase

    def locate_in_admin(self, user_id: str) -> PostgrestAPIResponse:
        return (
            self.supabase.table("admin_table")
            .select("*")
            .eq("user_id", f"{user_id}")
            .execute()
        )

    def generate_user(self, user_to_add: UserMongoBlueprint):
        print(user_to_add)
        return (
            self.supabase.table("user_roles")
            .insert(
                {
                    "user_id": user_to_add.supabase_id,
                    "role_name": user_to_add.role,
                }
            )
            .execute()
        )

    def generate_account(self, user_to_add: UserMongoBlueprint, roles_to_balance: dict):
        balance = roles_to_balance[user_to_add.role]
        return (
            self.supabase.table("accounts")
            .insert(
                {
                    "user_id": user_to_add.supabase_id,
                    "balance": f"{balance}",
                },
            )
            .execute()
        )

    def get_user_role(self, user_id: str):
        return (
            self.supabase.table("user_roles")
            .select("role_name")
            .eq("user_id", f"{user_id}")
            .execute()
        )

    def get_account_balance(self, user_id: str):
        return (
            self.supabase.table("accounts")
            .select("balance")
            .eq("user_id", f"{user_id}")
            .execute()
        )

    def get_in_wallet_balance(self, user_id: str):
        return (
            self.supabase.table("accounts")
            .select("in_wallet")
            .eq("user_id", f"{user_id}")
            .execute()
        )

    def gen_qr_procedure(
        self, user_id: str, new_balance: float, value_of_coupon: float, coupon_type: str
    ):
        try:
            response = (
                self.supabase.table("accounts")
                .update(
                    {"balance": f"{new_balance}", "in_wallet": f"{value_of_coupon}"}
                )
                .eq("user_id", user_id)
                .execute()
            )
            qr_data = {
                "user_id": user_id,
                "coupon_type": coupon_type,
                "nonce": "hellotherestoptrypingtodecryptthis",
            }
            jwt_encoded = jwt.encode(
                qr_data, parser["QR"]["secret_key"], algorithm="HS256"
            )
            try:
                response = self.supabase.table("generated_qrs").insert(
                    {
                        "user_id": user_id,
                        "jwt": jwt_encoded,
                        "scanned": f"{False}",
                        "banned": f"{False}",
                    }
                ).execute()
                return jwt_encoded
            except exceptions.APIError as err:
                raise HTTPException(
                    status_code=401, detail="RLS blocked access to qrs table"
                )
        except exceptions.APIError as err:
            raise HTTPException(
                status_code=401, detail="RLS blocked access to accounts"
            )
