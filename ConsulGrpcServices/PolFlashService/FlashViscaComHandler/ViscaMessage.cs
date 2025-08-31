using System.Text;

namespace FotoFinder.PolFlashXe.FlashViscaComHandler
{
    public class ViscaMessage
    {
        public byte[] Command { get; set; }
        public byte[] Reply { get; set; }     

        public string ReplyToString()
        {
            StringBuilder sr = new StringBuilder();

            if (Reply == null)
            {
                sr.Append("null");
            }
            else
            {
                foreach (byte b in Reply)
                {
                    sr.Append(b.ToString("X2"));
                    sr.Append(" ");
                }
            }
 
            return sr.ToString();
        }
    }
}