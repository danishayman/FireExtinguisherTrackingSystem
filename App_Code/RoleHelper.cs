using System;
using System.Web;
using System.Web.Security;

namespace FETS
{
    /// <summary>
    /// Helper class for managing user roles
    /// </summary>
    public static class RoleHelper
    {
        /// <summary>
        /// Gets the role of the currently authenticated user
        /// </summary>
        /// <returns>The user's role or empty string if not found</returns>
        public static string GetUserRole()
        {
            // Try to get role from session first (faster)
            if (HttpContext.Current.Session != null && HttpContext.Current.Session["UserRole"] != null)
            {
                return HttpContext.Current.Session["UserRole"].ToString();
            }

            // Otherwise try to get it from the authentication ticket
            HttpCookie authCookie = HttpContext.Current.Request.Cookies[FormsAuthentication.FormsCookieName];
            if (authCookie != null)
            {
                try
                {
                    FormsAuthenticationTicket ticket = FormsAuthentication.Decrypt(authCookie.Value);
                    if (ticket != null && !String.IsNullOrEmpty(ticket.UserData))
                    {
                        // Store in session for future use
                        if (HttpContext.Current.Session != null)
                        {
                            HttpContext.Current.Session["UserRole"] = ticket.UserData;
                        }
                        return ticket.UserData;
                    }
                }
                catch (Exception ex)
                {
                    // Log the exception
                    System.Diagnostics.Debug.WriteLine(string.Format("Error getting user role: {0}", ex.Message));
                }
            }

            return String.Empty;
        }

        /// <summary>
        /// Checks if the current user is in the specified role
        /// </summary>
        /// <param name="roleName">The role to check</param>
        /// <returns>True if the user is in the role, false otherwise</returns>
        public static bool IsUserInRole(string roleName)
        {
            string userRole = GetUserRole();
            return !String.IsNullOrEmpty(userRole) && userRole.Equals(roleName, StringComparison.OrdinalIgnoreCase);
        }
    }
} 