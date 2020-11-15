import com.github.elifkus.tweetapi._
import org.scalatra._
import javax.servlet.ServletContext
import org.scalatra.CorsSupport

class ScalatraBootstrap extends LifeCycle {
  override def init(context: ServletContext) {
    context.mount(new TweetApiServlet, "/*")

    //context.initParameters("org.scalatra.cors.allowedOrigins") = "http://localhost:9500"
    context.setInitParameter(CorsSupport.AllowedOriginsKey, "http://localhost:9500")
  }
}
