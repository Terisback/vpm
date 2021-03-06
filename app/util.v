module app

import time
import nedpals.vex.ctx
import models
import service

fn dummy(req &ctx.Req, mut res ctx.Resp) {
	res.send('Hello :)', 200)
}

fn authorized(user models.User) bool {
	return user.id != 0
}

fn wrap_service_error(req &ctx.Req, mut res ctx.Resp, err IError) {
	match err {
		service.NotFoundError {
			res.send_status(404)
			return
		}
		// Also known as constraint error
		service.AlreadyExists {
			res.send_status(422)
			return
		}
		else {
			errout(req, err)
			res.send_status(500)
			return
		}
	}
}

fn errout(req &ctx.Req, err IError) {
	eprintln('[ERR][$time.now().hhmmss()] $req.method $req.path : $err')
}
