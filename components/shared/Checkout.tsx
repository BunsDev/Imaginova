"use client";

import { loadStripe } from "@stripe/stripe-js";
import { useEffect, useState } from "react";
import { connectToNetwork, buyToken } from "../../utils/contract";
import ImaginovaABI from "../../utils/Imaginova.json";
import { ethers } from "ethers";
import { useToast } from "@/components/ui/use-toast";
import { checkoutCredits } from "@/lib/actions/transaction.action";
import { Button } from "../ui/button";
import { connectToDatabase } from "@/lib/database/mongoose";
import { updateCredits } from "@/lib/actions/user.actions";
import { handleError } from "@/lib/utils";
import { Loader, Loader2Icon, LoaderIcon } from "lucide-react";

interface CheckoutProps {
  plan: string;
  amount: number;
  credits: number;
  buyerId: string;
}

const Checkout: React.FC<CheckoutProps> = ({
  plan,
  amount,
  credits,
  buyerId,
}) => {
  const { toast } = useToast();

  const connectAndBuy = async () => {
    await connectToNetwork();
    console.log(plan);
    console.log(credits);

    const provider = new ethers.providers.Web3Provider(window.ethereum);
    await provider.send("eth_requestAccounts", []);
    const signer = provider.getSigner();

    const contractAddress = "0x0e2D26AA3981B3e2e274a7C27697043506F3B372";
    const contractABI = ImaginovaABI.abi;
    const etherAmount = plan === "Pro Package" ? 0.01 : 0.05; // Amount in Ether
    const packageType = plan === "Pro Package" ? 1 : 2;
    await buyToken(
      contractAddress,
      contractABI,
      etherAmount,
      packageType,
      signer
    );
  };

  const [isLoading, setIsLoading] = useState(false);
  const createTransaction = async () => {
    try {
      setIsLoading(true);
      // let isTnxComplete = await connectAndBuy();
      // let newTransaction = await updateCredits(buyerId, credits);
      // toast({
      //   title: "Credit Purchased!",
      //   description: "Your credits have been added successfully",
      //   duration: 5000,
      //   className: "success-toast",
      // });
      // setIsLoading(true);

      // return JSON.parse(JSON.stringify(newTransaction));
    } catch (error) {
      setIsLoading(false);
      toast({
        title: "Order canceled!",
        description: "Something went wrong",
        duration: 5000,
        className: "error-toast",
      });
      handleError(error);
    }
  };

  useEffect(() => {
    loadStripe(process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY!);
  }, []);

  useEffect(() => {
    const query = new URLSearchParams(window.location.search);
    if (query.get("success")) {
      toast({
        title: "Order placed!",
        description: "You will receive an email confirmation",
        duration: 5000,
        className: "success-toast",
      });
    }

    if (query.get("canceled")) {
      toast({
        title: "Order canceled!",
        description: "Continue to shop around and checkout when you're ready",
        duration: 5000,
        className: "error-toast",
      });
    }
  }, [toast]);

  const onCheckout = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault(); // Prevent form from submitting normally
    const transaction = {
      plan,
      amount,
      credits,
      buyerId,
    };
    await createTransaction();
  };

  return (
    <form onSubmit={onCheckout} method="POST">
      <section>
        <Button
          type="submit"
          role="link"
          className="w-full rounded-full bg-purple-gradient bg-cover"
        >
          {isLoading ? <Loader className="animate-spin" /> : ""}
          Buy Credit
        </Button>
      </section>
    </form>
  );
};

export default Checkout;
