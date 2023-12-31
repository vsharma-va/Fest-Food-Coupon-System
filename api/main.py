from fastapi import FastAPI
from routers.auth import auth
from routers.gen import gen_user
from routers.gen import gen_coupon
from routers.scan import scan

app = FastAPI()
app.include_router(auth.router)
app.include_router(gen_user.router)
app.include_router(gen_coupon.router)
app.include_router(scan.router)

