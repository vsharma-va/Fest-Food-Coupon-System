from fastapi import APIRouter, Request, Depends, Header, HTTPException
from pydantic import BaseModel
from global_var import supabase
import httpx
import gotrue
from db.supa import Supa

router = APIRouter()


class UserSignUp(BaseModel):
    # current requirements for sign up ->
    # username, email_id, password (hashed), batch
    username: str
    email_id: str
    password: str
    batch: str


class UserAuthState(BaseModel):
    access_token: str
    refresh_token: str
    supabase_id: str


async def check_auth_state(user_state: UserAuthState):
    try:
        supabase.auth.get_user(user_state.access_token)
        supabase.auth.set_session(
            access_token=user_state.access_token, refresh_token=user_state.refresh_token
        )
        supabase.auth.refresh_session()
        new_session = supabase.auth.get_session()
        new_state: UserAuthState = UserAuthState(
            access_token=new_session.access_token,
            refresh_token=new_session.refresh_token,
            supabase_id=new_session.user.id,
        )
        return new_state
    except gotrue.errors.AuthApiError as err:
        raise HTTPException(status_code=401, detail=f"{err}")

@router.post("/auth/checkAuthState/")
async def check_auth_state_route(user_auth_state: UserAuthState=Depends(check_auth_state)):
    return {"status": "200", "detail": {"user_state": user_auth_state}}

@router.post("/auth/signup/")
async def signup(user: UserSignUp) -> dict:
    try:
        response = supabase.auth.sign_up(
            {
                "email": user.email_id,
                "password": user.password,
                "options": {
                    "data": {
                        "username": user.username,
                        "batch": user.batch,
                    }
                },
            }
        )
        new_user: UserAuthState = UserAuthState(
            access_token=response.session.access_token,
            refresh_token=response.session.refresh_token,
            supabase_id=response.user.id,
        )
        return {
            "status": "200",
            "detail": {"user_state": new_user},
        }
    except httpx.HTTPStatusError as err:
        return {
            "status": f"{err.response.status_code}",
            "detail": f"{err.response.reason_phrase}",
        }
    except httpx.RequestError as err:
        print("What the fuck")
        return {"h": "h"}
    except gotrue.errors.AuthApiError as err:
        return {"status": "400", "detail": f"{err}"}


@router.post("/auth/signin/")
async def signin(
    user: UserSignUp
):
    try:
        response = supabase.auth.sign_in_with_password(
            {
                "email": f"{user.email_id}",
                "password": f"{user.password}",
            }
        )
        new_user: UserAuthState = UserAuthState(
            access_token=response.session.access_token,
            refresh_token=response.session.refresh_token,
            supabase_id=response.user.id,
        )
        return {
            "status": "200",
            "detail": {"user_state": new_user},
        }
    except gotrue.errors.AuthApiError as err:
        return {"status": "400", "detail": f"{err}"}
    
@router.post("/auth/logout/", dependencies=[Depends(check_auth_state)])
async def logout():
    supabase.auth.sign_out()
    return {
        "status": "200",
        "detail": "logged out successfully"
    }


@router.post("/auth/isAdmin/{user_id}")
async def check_admin_status(
    user_id: str, user_state: UserAuthState = Depends(check_auth_state)
):
    try:
        db_client = Supa(supabase)
        response = db_client.locate_in_admin(user_id)
        if len(response.data) > 0:
            return {
                "status": "200",
                "detail": {"is_admin": True, "user_state": user_state},
            }
        else:
            return {
                "status": "200",
                "detail": {"is_admin": False, "user_state": user_state},
            }
    except gotrue.errors.AuthApiError as err:
        return {"status": "400", "detail": f"{err}"}
